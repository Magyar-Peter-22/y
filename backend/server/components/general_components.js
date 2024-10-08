import { Validator } from "node-input-validator";
import { postQuery } from "./post_query.js";
import { CheckErr, CheckV } from "./validations.js";


async function CountableToggleSimplified(req, res, table, unique_constraint_name, first_column_name = "user_id", second_column_name = "post_id") {
    async function onAdd(key, user_id) {
        await db.query(named("INSERT INTO " + table + " (" + first_column_name + ", " + second_column_name + ") VALUES (:user,:key) ON CONFLICT ON CONSTRAINT " + unique_constraint_name + " DO NOTHING")({ user: user_id, key: key }));
    }

    async function onRemove(key, user_id) {
        await db.query(named("DELETE FROM " + table + " WHERE " + first_column_name + "=:user AND " + second_column_name + "=:key")({ user: user_id, key: key }));
    }

    await CountableToggle(req, res, onAdd, onRemove);
}

async function CountableToggle(req, res, onAdd, onRemove) {
    const v = new Validator(req.body, {
        key: 'required|integer',
        value: "required|boolean"
    });
    await CheckV(v);
    const { key, value } = req.body;
    const user_id = UserId(req);
    try {
        if (value) {
            await onAdd(key, user_id);
        }
        else
            await onRemove(key, user_id);
        res.sendStatus(200);
    }
    catch (err) {
        CheckErr(err);
    }
}

async function GetPosts(user_id, where, where_params, limit, offset = 0, posts_query, level) {
    const params = { user_id: user_id, ...where_params };

    //getting the posts
    const text = postQuery(where, offset, limit, posts_query);
    const posts_q = await db.query(named(text)(params));
    const posts = posts_q.rows;

    //add other data
    await add_data_to_posts(posts, user_id, level);

    return posts;
}

//adds the necessary data about the replied, reposted and quoted posts and counts the views
async function add_data_to_posts(posts, user_id, level = 0) {
    //for each comment, getting the name of the replied user
    ///  const comments = posts.filter(post => post.replying_to !== null);
    ///  if (comments.length !== 0) {
    ///      const replied_ids = [];
    ///      comments.forEach(comment => {
    ///          const replied_id = comment.replying_to;
    ///          if (!replied_ids.includes(replied_id))
    ///              replied_ids.push(replied_id);
    ///      });
    ///      const replied_query = await db.query(named("SELECT POST.ID as post_id, POSTER.ID, POSTER.USERNAME, POSTER.NAME FROM POSTS POST LEFT JOIN USERS POSTER ON POSTER.ID = POST.PUBLISHER WHERE POST.ID = ANY(:ids)")({ ids: replied_ids }));
    ///      const replied_users = replied_query.rows;
    ///      comments.forEach(comment => {
    ///          const myUser = replied_users.find(user => user.post_id === comment.replying_to);
    ///          comment.replied_user = myUser;
    ///      });
    ///  }

    //adding the referenced post to each repost or quote
    //level means how much parent posts are above this post
    if (level < 2) {
        //getting the ids of the reposted posts
        const reposted_ids = [];
        posts.forEach(post => {
            if (post.reposted_id !== null) {
                reposted_ids.push(post.reposted_id);
            }
        });
        if (reposted_ids.length !== 0) {
            //downloading the reposted posts and assigning them to their reposter
            const reposted_posts = await GetPosts(user_id, " WHERE post.id=ANY(:reposted_ids)", { reposted_ids: reposted_ids }, 999, undefined, undefined, level);

            posts.forEach(post => {
                if (post.reposted_id !== null) {
                    const my_reposted_post = reposted_posts.find(reposted => post.reposted_id === reposted.id);
                    if (my_reposted_post === undefined)
                        throw new Error("failed to download the reposted post");
                    post.reposted_post = my_reposted_post;
                }
            })
        }
    }

    await updateViews(posts, user_id);//the viewcount update is not awaited
}


async function editable_query(text, before, after, params, additional_params) {
    if (after !== undefined)
        text += after;
    if (before !== undefined)
        text = before + text;
    if (additional_params)
        params = { ...params, ...additional_params };

    const result = await db.query(named(text)(params));
    return result.rows;
}

async function updateViews(posts, user_id) {
    const ids = posts.map((post) => post.id);
    try {
        await db.query(named(`
    insert into views (post_id, user_id)
    select UNNEST(:post_ids::int[]),:user_id 
    ON CONFLICT ON CONSTRAINT unique_view DO NOTHING
    `)
            ({
                post_ids: ids,
                user_id: user_id
            }));
    }
    catch (err) {
        CheckErr(err);
    }
}

const timeFilter = "where post.date<=to_timestamp(:timestamp) and (post.deleted is null or post.deleted > to_timestamp(:timestamp))";

async function post_list(req, res, add_validations, where, where_params = {}, posts_query, where_timestamp = timeFilter) {
    //validate inputs
    let validations = { from: "required|integer", timestamp: "required|integer" };
    if (add_validations)
        validations = { ...validations, ...add_validations };
    const v = new Validator(req.body, validations);
    await CheckV(v);

    //filter out the posts those were created after this feed began
    if (where)
        where = where_timestamp + " and " + where;
    else where = where_timestamp;

    //add the timestamp to the where parameters
    const { from, timestamp } = req.body;
    where_params = { ...where_params, timestamp };

    //get the posts
    const posts = await GetPosts(UserId(req), where, where_params, undefined, from, posts_query);
    res.json(posts);
}

export { CountableToggle, CountableToggleSimplified, editable_query, GetPosts, post_list, updateViews };
