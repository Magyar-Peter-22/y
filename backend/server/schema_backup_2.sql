PGDMP         9        	        |           y    15.4    15.4 t    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    49984    y    DATABASE     x   CREATE DATABASE y WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Hungarian_Hungary.1250';
    DROP DATABASE y;
                postgres    false            �           1247    91208    notification    TYPE     c   CREATE TYPE public.notification AS ENUM (
    'like',
    'follow',
    'repost',
    'comment'
);
    DROP TYPE public.notification;
       public          postgres    false            �            1255    91183    cache_bookmark_count_trg()    FUNCTION     �  CREATE FUNCTION public.cache_bookmark_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	bookmarked_post integer;
BEGIN
  --get the reposted post id
	IF TG_OP IN ('INSERT') THEN
		bookmarked_post:=new.post_id;
	ELSE
		bookmarked_post:=old.post_id;
	END IF;
	
	--update counter
 	UPDATE posts
	SET bookmark_count = (select count(*) from bookmarks where bookmarks.post_id=posts.id)
	WHERE posts.id = bookmarked_post;
	
  	RETURN NULL;
END$$;
 1   DROP FUNCTION public.cache_bookmark_count_trg();
       public          postgres    false            �            1255    91175    cache_comment_count_trg()    FUNCTION       CREATE FUNCTION public.cache_comment_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	replied_post integer;
BEGIN
	--get the replied post id
	IF TG_OP IN ('INSERT') THEN
		replied_post:=new.replying_to;
	ELSE
		replied_post:=old.replying_to;
	END IF;
	
	--if this is not a comment, ignore
	IF replied_post IS NULL THEN
		RETURN NULL;
	END IF;	
	
	--update count
 	UPDATE posts
	SET comment_count = (select count(*) from posts where posts.replying_to=replied_post)
	WHERE posts.id = replied_post;
  	RETURN NULL;
END
$$;
 0   DROP FUNCTION public.cache_comment_count_trg();
       public          postgres    false            �            1255    115711    cache_follower_counts_trg()    FUNCTION     �  CREATE FUNCTION public.cache_follower_counts_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	i_follower integer;
	i_followed integer;
BEGIN
	--select the post id from 'new' or 'old'
	IF TG_OP IN ('INSERT') THEN
		i_follower:=new.follower;
		i_followed:=new.followed;
	ELSE
		i_follower:=old.follower;
		i_followed:=old.followed;
	END IF;
	
	--update count
 	UPDATE users
	SET follower_count = (select count(*) from follows where followed=i_followed)
	WHERE users.id = i_followed;
	
	UPDATE users
	SET following_count = (select count(*) from follows where follower=i_follower)
	WHERE users.id = i_follower;
	
  	RETURN NULL;
END$$;
 2   DROP FUNCTION public.cache_follower_counts_trg();
       public          postgres    false            �            1255    91161    cache_hashtag_count_trg()    FUNCTION     O  CREATE FUNCTION public.cache_hashtag_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	INSERT INTO trends (hashtag,count)
	VALUES(new.hashtag,1)
	ON CONFLICT (hashtag)
    DO UPDATE  
	SET count = (select count(*) from hashtags where hashtag=trends.hashtag)
	WHERE trends.hashtag = new.hashtag;
  RETURN NULL;
END
$$;
 0   DROP FUNCTION public.cache_hashtag_count_trg();
       public          postgres    false            �            1255    91284    cache_like_count_trg()    FUNCTION     �  CREATE FUNCTION public.cache_like_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	post integer;
BEGIN
	--select the post id from 'new' or 'old'
	IF TG_OP IN ('INSERT') THEN
		post:=new.post_id;
	ELSE
		post:=old.post_id;
	END IF;
	
	--update count
 	UPDATE posts
	SET like_count = (select count(*) from likes where post_id=posts.id)
	WHERE posts.id = post;
	
  	RETURN NULL;
END$$;
 -   DROP FUNCTION public.cache_like_count_trg();
       public          postgres    false            �            1255    91281    cache_replied_user_trg()    FUNCTION     �   CREATE FUNCTION public.cache_replied_user_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF new.replying_to IS NOT NULL THEN
		new.replying_to_user=(SELECT PUBLISHER FROM POSTS WHERE ID=new.REPLYING_TO);
	END IF;
	RETURN new;
END
$$;
 /   DROP FUNCTION public.cache_replied_user_trg();
       public          postgres    false            �            1255    91180    cache_repost_count_trg()    FUNCTION       CREATE FUNCTION public.cache_repost_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	reposted_post integer;
BEGIN
  --get the reposted post id
	IF TG_OP IN ('INSERT') THEN
		reposted_post:=new.repost;
	ELSE
		reposted_post:=old.repost;
	END IF;
	
	--if this is not a repost, ignore
	IF reposted_post IS NULL THEN
		RETURN NULL;
	END IF;	
	
	--update counter
 	UPDATE posts
	SET repost_count = (select count(*) from posts as reposts where reposts.repost=posts.id)
	WHERE posts.id = reposted_post;
  	RETURN NULL;
END
$$;
 /   DROP FUNCTION public.cache_repost_count_trg();
       public          postgres    false            �            1255    99307 %   cache_unread_notification_count_trg()    FUNCTION       CREATE FUNCTION public.cache_unread_notification_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	my_user_id integer;
BEGIN
	--select the user id from 'new' or 'old'
	IF TG_OP IN ('INSERT','UPDATE') THEN
		my_user_id:=new.user_id;
	ELSE
		my_user_id:=old.user_id;
	END IF;
	
	--update count
 	UPDATE users
	SET unread_notification_count = (
		select count(*) from notifications
		where notifications.user_id=my_user_id 
		and notifications.seen=false
	)
	WHERE users.id = my_user_id;
	
  	RETURN NULL;
END$$;
 <   DROP FUNCTION public.cache_unread_notification_count_trg();
       public          postgres    false            �            1255    91178    cache_view_count_trg()    FUNCTION     �  CREATE FUNCTION public.cache_view_count_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	post integer;
BEGIN
	--select the post id from 'new' or 'old'
	IF TG_OP IN ('INSERT') THEN
		post:=new.post_id;
	ELSE
		post:=new.post_id;
	END IF;
	
	--update count
 	UPDATE posts
	SET view_count = (select count(*) from views where post_id=posts.id)
	WHERE posts.id = post;
	
  	RETURN NULL;
END
$$;
 -   DROP FUNCTION public.cache_view_count_trg();
       public          postgres    false            �            1255    91146    count_estimate(text)    FUNCTION     �   CREATE FUNCTION public.count_estimate(query text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    plan jsonb;
BEGIN
    EXECUTE 'EXPLAIN (FORMAT JSON)' || query INTO plan;
    RETURN plan->0->'Plan'->'Plan Rows';
END;
$$;
 1   DROP FUNCTION public.count_estimate(query text);
       public          postgres    false            �            1255    91246 !   create_comment_notification_trg()    FUNCTION     �  CREATE FUNCTION public.create_comment_notification_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	--on insert, create a new notification if necessary

		--if this is not a comment, ignore
		IF new.replying_to IS NULL THEN
			RETURN NULL;
		END IF;
		
		--exit if the user is commenting to itself
		IF new.replying_to_user=new.publisher THEN
			RETURN NULL;
		END IF;

		--insert new notification
 		INSERT INTO notifications (type,user_id,post_id,comment_id)
		VALUES(
			'comment',
			new.replying_to_user,
			new.replying_to,
			new.id
		)
		ON CONFLICT (user_id,post_id,comment_id,type) WHERE seen=FALSE
		DO NOTHING;
		
	RETURN NULL;
END
$$;
 8   DROP FUNCTION public.create_comment_notification_trg();
       public          postgres    false            �            1255    91259     create_follow_notification_trg()    FUNCTION     �  CREATE FUNCTION public.create_follow_notification_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	followed_user_id integer;
	follow_count integer;
BEGIN
	--getting the user id either from 'new' or 'old'
		followed_user_id:=new.followed;

	--creating a new notification, or updating an existing unread notification

		--on insert, try to insert or update
		INSERT INTO notifications (type,user_id)
		VALUES(
			'follow',
			followed_user_id
		)
		ON CONFLICT (user_id,post_id,type,comment_id) WHERE seen=FALSE
		DO UPDATE SET 
		count=(
			select count(*) from follows 
			where follows.followed=followed_user_id 
			and follows.timestamp>=notifications.date
		);
	
	RETURN NULL;
END
$$;
 7   DROP FUNCTION public.create_follow_notification_trg();
       public          postgres    false            �            1255    91249    create_like_notification_trg()    FUNCTION     �  CREATE FUNCTION public.create_like_notification_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	liked_post_id integer;
	liker_user integer;
	like_count integer;
	liked_user integer;
BEGIN
	--getting the post id either from 'new' or 'old'

		liked_post_id:=new.post_id;
		liker_user:=new.user_id;
	
	--getting the user who will recieve the notification
	liked_user:=(SELECT posts.publisher from posts where posts.id=liked_post_id);
	
	--no notification if the user likes it's own post
	IF liked_user=liker_user THEN
		RETURN NULL;
	END IF;
	
	--creating a new notification, or updating an existing unread notification
		--on insert, try to insert or update
		INSERT INTO notifications (type,user_id,post_id)
		VALUES(
			'like',
			liked_user,
			liked_post_id
		)
		ON CONFLICT (user_id,post_id,type,comment_id) WHERE seen=FALSE
		DO UPDATE SET 
		count=(
			select count(*) from likes 
			where likes.post_id=notifications.post_id 
			and likes.timestamp>=notifications.date
		);

	RETURN NULL;
END
$$;
 5   DROP FUNCTION public.create_like_notification_trg();
       public          postgres    false            �            1255    91253     create_repost_notification_trg()    FUNCTION       CREATE FUNCTION public.create_repost_notification_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	reposted_post_id integer;
	repost_publisher integer;
	reposter integer;
BEGIN
	--getting the post id either from 'new' or 'old'
		reposted_post_id:=new.repost;
		reposter:=new.publisher;
	
	--if this is not a repost, ignore
	IF(reposted_post_id IS NULL) THEN
		RETURN NULL;
	END IF;
	
	--get the publisher of the reposted post
	repost_publisher:=(SELECT posts.publisher from posts where posts.id=reposted_post_id);
	
	--if the user repost his own post, ignore
	IF repost_publisher=reposter THEN
		RETURN NULL;
	END IF;
	
	--creating a new notification, or updating an existing unread notification
	INSERT INTO notifications (type,user_id,post_id)
	VALUES(
		'repost',
		repost_publisher,
		reposted_post_id
	)
	ON CONFLICT (user_id,post_id,type,comment_id) WHERE seen=FALSE
	DO UPDATE SET 
	count=(
		select count(*) from posts 
		where posts.repost=notifications.post_id 
		and posts.date>=notifications.date
	);
	
	RETURN NULL;
END$$;
 7   DROP FUNCTION public.create_repost_notification_trg();
       public          postgres    false            �            1255    91273    repost_cant_be_reposted_trg()    FUNCTION     ^  CREATE FUNCTION public.repost_cant_be_reposted_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
	reposted_repost boolean;
BEGIN
	--if this is a repost, and the reposted post is also a repost (not a quote) then throw an error
	IF new.repost IS NULL THEN
		RETURN new;
	END IF;
	
	--get if the reposted post is a repost or not
	reposted_repost:= 
		(
			SELECT (repost IS NOT NULL AND text IS NULL) as not_okay
			FROM POSTS WHERE POSTS.ID=NEW.REPOST
		);
		
	--if its a repost, throw error
	IF reposted_repost THEN
		RAISE EXCEPTION	'a repost cannot be reposted';	
	END IF;
	
	RETURN new;
END$$;
 4   DROP FUNCTION public.repost_cant_be_reposted_trg();
       public          postgres    false            �            1259    91072    blocks    TABLE     [   CREATE TABLE public.blocks (
    blocker integer NOT NULL,
    blocked integer NOT NULL
);
    DROP TABLE public.blocks;
       public         heap    postgres    false            �            1259    82756 	   bookmarks    TABLE     �   CREATE TABLE public.bookmarks (
    user_id integer,
    post_id integer,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL
);
    DROP TABLE public.bookmarks;
       public         heap    postgres    false            �            1259    74573    follows    TABLE     �   CREATE TABLE public.follows (
    follower integer,
    followed integer,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT cannot_follow_itself CHECK ((follower <> followed))
);
    DROP TABLE public.follows;
       public         heap    postgres    false            �            1259    91110    hashtags    TABLE     k   CREATE TABLE public.hashtags (
    post_id integer NOT NULL,
    hashtag character varying(50) NOT NULL
);
    DROP TABLE public.hashtags;
       public         heap    postgres    false            �            1259    74606    likes    TABLE     �   CREATE TABLE public.likes (
    user_id integer,
    post_id integer,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL
);
    DROP TABLE public.likes;
       public         heap    postgres    false            �            1259    91185    notifications    TABLE     �  CREATE TABLE public.notifications (
    user_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    post_id integer,
    count integer DEFAULT 1 NOT NULL,
    type public.notification NOT NULL,
    comment_id integer,
    seen boolean DEFAULT false NOT NULL,
    CONSTRAINT comment_id_nn CHECK (((type <> 'comment'::public.notification) OR (comment_id IS NOT NULL))),
    CONSTRAINT post_id_nn CHECK (((type = 'follow'::public.notification) OR (post_id IS NOT NULL)))
);
 !   DROP TABLE public.notifications;
       public         heap    postgres    false    902    902    902            �            1259    91087    password_changes    TABLE     �   CREATE TABLE public.password_changes (
    id integer,
    secret integer DEFAULT floor((random() * (2147483647)::double precision)) NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL
);
 $   DROP TABLE public.password_changes;
       public         heap    postgres    false            �            1259    74587    posts    TABLE     �  CREATE TABLE public.posts (
    id integer NOT NULL,
    publisher integer,
    text text,
    date timestamp without time zone DEFAULT now() NOT NULL,
    repost integer,
    views integer DEFAULT 0 NOT NULL,
    replying_to integer,
    media jsonb[],
    hashtags character varying(50)[],
    like_count integer DEFAULT 0 NOT NULL,
    comment_count integer DEFAULT 0 NOT NULL,
    view_count integer DEFAULT 0 NOT NULL,
    repost_count integer DEFAULT 0 NOT NULL,
    bookmark_count integer DEFAULT 0 NOT NULL,
    replying_to_user integer,
    deleted timestamp without time zone,
    CONSTRAINT replying_to_user_nn CHECK (((replying_to IS NULL) OR (replying_to_user IS NOT NULL)))
);
    DROP TABLE public.posts;
       public         heap    postgres    false            �            1259    74586    posts_id_seq    SEQUENCE     �   CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.posts_id_seq;
       public          postgres    false    219            �           0    0    posts_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;
          public          postgres    false    218            �            1259    66368    session    TABLE     �   CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);
    DROP TABLE public.session;
       public         heap    postgres    false            �            1259    91154    trends    TABLE     �   CREATE TABLE public.trends (
    id integer NOT NULL,
    hashtag character varying(50) NOT NULL,
    count integer DEFAULT 0 NOT NULL
);
    DROP TABLE public.trends;
       public         heap    postgres    false            �            1259    91153    trends_id_seq    SEQUENCE     �   CREATE SEQUENCE public.trends_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.trends_id_seq;
       public          postgres    false    227            �           0    0    trends_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.trends_id_seq OWNED BY public.trends.id;
          public          postgres    false    226            �            1259    50015    users    TABLE     �  CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    email character varying(50),
    password_hash character varying(255),
    registration_date timestamp without time zone DEFAULT now() NOT NULL,
    birthdate date NOT NULL,
    bio text,
    picture jsonb,
    banner jsonb,
    follower_count integer DEFAULT 0 NOT NULL,
    last_check_notifs timestamp without time zone DEFAULT now() NOT NULL,
    push_sub jsonb,
    unread_notification_count integer DEFAULT 0 NOT NULL,
    last_email_notifications integer DEFAULT 0 NOT NULL,
    following_count integer DEFAULT 0 NOT NULL,
    settings jsonb,
    ip inet
);
    DROP TABLE public.users;
       public         heap    postgres    false            �            1259    50014    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    215            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    214            �            1259    91057    views    TABLE     Z   CREATE TABLE public.views (
    post_id integer NOT NULL,
    user_id integer NOT NULL
);
    DROP TABLE public.views;
       public         heap    postgres    false            �           2604    74590    posts id    DEFAULT     d   ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);
 7   ALTER TABLE public.posts ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    218    219            �           2604    91157 	   trends id    DEFAULT     f   ALTER TABLE ONLY public.trends ALTER COLUMN id SET DEFAULT nextval('public.trends_id_seq'::regclass);
 8   ALTER TABLE public.trends ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    227    226    227            �           2604    50018    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    214    215    215            �           2606    82789    follows follow_unique 
   CONSTRAINT     ^   ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follow_unique UNIQUE (follower, followed);
 ?   ALTER TABLE ONLY public.follows DROP CONSTRAINT follow_unique;
       public            postgres    false    217    217            �           2606    91114    hashtags hashtag_unique 
   CONSTRAINT     c   ALTER TABLE ONLY public.hashtags
    ADD CONSTRAINT hashtag_unique PRIMARY KEY (post_id, hashtag);
 A   ALTER TABLE ONLY public.hashtags DROP CONSTRAINT hashtag_unique;
       public            postgres    false    225    225            �           2606    74595    posts posts_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.posts DROP CONSTRAINT posts_pkey;
       public            postgres    false    219            �           2606    66374    session session_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);
 >   ALTER TABLE ONLY public.session DROP CONSTRAINT session_pkey;
       public            postgres    false    216            �           2606    91164    trends trend_unique 
   CONSTRAINT     Q   ALTER TABLE ONLY public.trends
    ADD CONSTRAINT trend_unique UNIQUE (hashtag);
 =   ALTER TABLE ONLY public.trends DROP CONSTRAINT trend_unique;
       public            postgres    false    227            �           2606    91160    trends trends_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.trends
    ADD CONSTRAINT trends_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.trends DROP CONSTRAINT trends_pkey;
       public            postgres    false    227            �           2606    91076    blocks unique_blocks 
   CONSTRAINT     [   ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT unique_blocks UNIQUE (blocker, blocked);
 >   ALTER TABLE ONLY public.blocks DROP CONSTRAINT unique_blocks;
       public            postgres    false    223    223            �           2606    82770    bookmarks unique_bookmarks 
   CONSTRAINT     a   ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT unique_bookmarks UNIQUE (user_id, post_id);
 D   ALTER TABLE ONLY public.bookmarks DROP CONSTRAINT unique_bookmarks;
       public            postgres    false    221    221            �           2606    82755    likes unique_likes 
   CONSTRAINT     Y   ALTER TABLE ONLY public.likes
    ADD CONSTRAINT unique_likes UNIQUE (user_id, post_id);
 <   ALTER TABLE ONLY public.likes DROP CONSTRAINT unique_likes;
       public            postgres    false    220    220            �           2606    91098    password_changes unique_user_id 
   CONSTRAINT     X   ALTER TABLE ONLY public.password_changes
    ADD CONSTRAINT unique_user_id UNIQUE (id);
 I   ALTER TABLE ONLY public.password_changes DROP CONSTRAINT unique_user_id;
       public            postgres    false    224            �           2606    91071    views unique_view 
   CONSTRAINT     X   ALTER TABLE ONLY public.views
    ADD CONSTRAINT unique_view UNIQUE (post_id, user_id);
 ;   ALTER TABLE ONLY public.views DROP CONSTRAINT unique_view;
       public            postgres    false    222    222            �           2606    50023    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            postgres    false    215            �           2606    74572    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    215            �           2606    50021    users users_username_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_key;
       public            postgres    false    215            �           1259    66375    IDX_session_expire    INDEX     J   CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);
 (   DROP INDEX public."IDX_session_expire";
       public            postgres    false    216            �           1259    115703    blocked_by_user_idx    INDEX     R   CREATE INDEX blocked_by_user_idx ON public.blocks USING btree (blocker, blocked);
 '   DROP INDEX public.blocked_by_user_idx;
       public            postgres    false    223    223            �           1259    115708    bookmarks_of_post_idx    INDEX     `   CREATE INDEX bookmarks_of_post_idx ON public.bookmarks USING btree (post_id, "timestamp" DESC);
 )   DROP INDEX public.bookmarks_of_post_idx;
       public            postgres    false    221    221            �           1259    115705    bookmarks_of_user_idx    INDEX     i   CREATE INDEX bookmarks_of_user_idx ON public.bookmarks USING btree (user_id, post_id, "timestamp" DESC);
 )   DROP INDEX public.bookmarks_of_user_idx;
       public            postgres    false    221    221    221            �           1259    115768    celebrities_idx    INDEX     T   CREATE INDEX celebrities_idx ON public.users USING btree (follower_count DESC, id);
 #   DROP INDEX public.celebrities_idx;
       public            postgres    false    215    215            �           1259    115763    contents_of_user_idx    INDEX     q   CREATE INDEX contents_of_user_idx ON public.posts USING btree (publisher, ((text IS NULL)), date DESC, id DESC);
 (   DROP INDEX public.contents_of_user_idx;
       public            postgres    false    219    219    219    219            �           1259    124549    email_notifications_idx    INDEX       CREATE INDEX email_notifications_idx ON public.users USING btree (unread_notification_count, last_email_notifications) WITH (deduplicate_items='false') WHERE ((((settings -> 'email_enabled'::text))::boolean = true) AND (unread_notification_count > 0) AND (email IS NOT NULL));
 +   DROP INDEX public.email_notifications_idx;
       public            postgres    false    215    215    215    215    215            �           1259    115779    fki_follows_followed_fkey    INDEX     Q   CREATE INDEX fki_follows_followed_fkey ON public.follows USING btree (followed);
 -   DROP INDEX public.fki_follows_followed_fkey;
       public            postgres    false    217            �           1259    115785    fki_follows_follower_fkey    INDEX     Q   CREATE INDEX fki_follows_follower_fkey ON public.follows USING btree (follower);
 -   DROP INDEX public.fki_follows_follower_fkey;
       public            postgres    false    217            �           1259    115791    fki_passwordchanges_id_fkey2    INDEX     W   CREATE INDEX fki_passwordchanges_id_fkey2 ON public.password_changes USING btree (id);
 0   DROP INDEX public.fki_passwordchanges_id_fkey2;
       public            postgres    false    224            �           1259    115767    followed_by_user_idx    INDEX     ^   CREATE INDEX followed_by_user_idx ON public.follows USING btree (follower, "timestamp" DESC);
 (   DROP INDEX public.followed_by_user_idx;
       public            postgres    false    217    217            �           1259    115766    followers_of_user_idx    INDEX     _   CREATE INDEX followers_of_user_idx ON public.follows USING btree (followed, "timestamp" DESC);
 )   DROP INDEX public.followers_of_user_idx;
       public            postgres    false    217    217            �           1259    115771    hashtag_idx    INDEX     C   CREATE INDEX hashtag_idx ON public.hashtags USING btree (hashtag);
    DROP INDEX public.hashtag_idx;
       public            postgres    false    225            �           1259    115707    id_idx    INDEX     A   CREATE INDEX id_idx ON public.password_changes USING btree (id);
    DROP INDEX public.id_idx;
       public            postgres    false    224            �           1259    115734    is_followed    INDEX     M   CREATE INDEX is_followed ON public.follows USING btree (followed, follower);
    DROP INDEX public.is_followed;
       public            postgres    false    217    217            �           1259    115700    likes_of_post_idx    INDEX     a   CREATE INDEX likes_of_post_idx ON public.likes USING btree (post_id, user_id, "timestamp" DESC);
 %   DROP INDEX public.likes_of_post_idx;
       public            postgres    false    220    220    220            �           1259    115698    likes_of_user_idx    INDEX     X   CREATE INDEX likes_of_user_idx ON public.likes USING btree (user_id, "timestamp" DESC);
 %   DROP INDEX public.likes_of_user_idx;
       public            postgres    false    220    220            �           1259    115773    notifs_of_user_idx    INDEX     `   CREATE INDEX notifs_of_user_idx ON public.notifications USING btree (user_id, seen, date DESC);
 &   DROP INDEX public.notifs_of_user_idx;
       public            postgres    false    228    228    228            �           1259    107495    posts_id_idx    INDEX     <   CREATE INDEX posts_id_idx ON public.posts USING btree (id);
     DROP INDEX public.posts_id_idx;
       public            postgres    false    219            �           1259    115760    posts_or_comments_idx    INDEX     b   CREATE INDEX posts_or_comments_idx ON public.posts USING btree (replying_to, date DESC, id DESC);
 )   DROP INDEX public.posts_or_comments_idx;
       public            postgres    false    219    219    219            �           1259    115761    reposter_of_post_idx    INDEX     w   CREATE INDEX reposter_of_post_idx ON public.posts USING btree (repost, date DESC, id DESC) WHERE (repost IS NOT NULL);
 (   DROP INDEX public.reposter_of_post_idx;
       public            postgres    false    219    219    219    219            �           1259    115769    search_name_idx    INDEX     V   CREATE INDEX search_name_idx ON public.users USING btree (name, follower_count DESC);
 #   DROP INDEX public.search_name_idx;
       public            postgres    false    215    215            �           1259    115770    search_username_idx    INDEX     ^   CREATE INDEX search_username_idx ON public.users USING btree (username, follower_count DESC);
 '   DROP INDEX public.search_username_idx;
       public            postgres    false    215    215            �           1259    115772    trends_search_idx    INDEX     N   CREATE INDEX trends_search_idx ON public.trends USING btree (hashtag, count);
 %   DROP INDEX public.trends_search_idx;
       public            postgres    false    227    227            �           1259    90990    unique_repost    INDEX     h   CREATE UNIQUE INDEX unique_repost ON public.posts USING btree (publisher, repost) WHERE (text IS NULL);
 !   DROP INDEX public.unique_repost;
       public            postgres    false    219    219    219            �           1259    91268    unique_unread    INDEX     �   CREATE UNIQUE INDEX unique_unread ON public.notifications USING btree (user_id, post_id, type, comment_id) NULLS NOT DISTINCT WITH (deduplicate_items='true') WHERE (seen = false);
 !   DROP INDEX public.unique_unread;
       public            postgres    false    228    228    228    228    228            �           1259    115686    users_id_idx    INDEX     <   CREATE INDEX users_id_idx ON public.users USING btree (id);
     DROP INDEX public.users_id_idx;
       public            postgres    false    215            �           1259    115699    views_of_post_idx    INDEX     O   CREATE INDEX views_of_post_idx ON public.views USING btree (post_id, user_id);
 %   DROP INDEX public.views_of_post_idx;
       public            postgres    false    222    222                       2620    91184    bookmarks cache_bookmark_count    TRIGGER     �   CREATE TRIGGER cache_bookmark_count AFTER INSERT OR DELETE ON public.bookmarks FOR EACH ROW EXECUTE FUNCTION public.cache_bookmark_count_trg();
 7   DROP TRIGGER cache_bookmark_count ON public.bookmarks;
       public          postgres    false    242    221                       2620    91176    posts cache_comment_count    TRIGGER     �   CREATE TRIGGER cache_comment_count AFTER INSERT OR DELETE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.cache_comment_count_trg();
 2   DROP TRIGGER cache_comment_count ON public.posts;
       public          postgres    false    219    245                       2620    115712    follows cache_follower_counts    TRIGGER     �   CREATE TRIGGER cache_follower_counts AFTER INSERT OR DELETE ON public.follows FOR EACH ROW EXECUTE FUNCTION public.cache_follower_counts_trg();
 6   DROP TRIGGER cache_follower_counts ON public.follows;
       public          postgres    false    217    249                       2620    91285    likes cache_like_count    TRIGGER     �   CREATE TRIGGER cache_like_count AFTER INSERT OR DELETE ON public.likes FOR EACH ROW EXECUTE FUNCTION public.cache_like_count_trg();
 /   DROP TRIGGER cache_like_count ON public.likes;
       public          postgres    false    251    220                       2620    91282    posts cache_replied_user    TRIGGER        CREATE TRIGGER cache_replied_user BEFORE INSERT ON public.posts FOR EACH ROW EXECUTE FUNCTION public.cache_replied_user_trg();
 1   DROP TRIGGER cache_replied_user ON public.posts;
       public          postgres    false    219    247                       2620    91181    posts cache_repost_count    TRIGGER     �   CREATE TRIGGER cache_repost_count AFTER INSERT OR DELETE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.cache_repost_count_trg();
 1   DROP TRIGGER cache_repost_count ON public.posts;
       public          postgres    false    244    219                       2620    99308 -   notifications cache_unread_notification_count    TRIGGER     �   CREATE TRIGGER cache_unread_notification_count AFTER INSERT OR DELETE OR UPDATE OF seen ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.cache_unread_notification_count_trg();
 F   DROP TRIGGER cache_unread_notification_count ON public.notifications;
       public          postgres    false    228    228    246                       2620    91179    views cache_view_count    TRIGGER     �   CREATE TRIGGER cache_view_count AFTER INSERT OR DELETE ON public.views FOR EACH ROW EXECUTE FUNCTION public.cache_view_count_trg();
 /   DROP TRIGGER cache_view_count ON public.views;
       public          postgres    false    222    248                       2620    91247 !   posts create_comment_notification    TRIGGER     �   CREATE TRIGGER create_comment_notification AFTER INSERT ON public.posts FOR EACH ROW EXECUTE FUNCTION public.create_comment_notification_trg();
 :   DROP TRIGGER create_comment_notification ON public.posts;
       public          postgres    false    219    243                       2620    91269 "   follows create_follow_notification    TRIGGER     �   CREATE TRIGGER create_follow_notification AFTER INSERT ON public.follows FOR EACH ROW EXECUTE FUNCTION public.create_follow_notification_trg();
 ;   DROP TRIGGER create_follow_notification ON public.follows;
       public          postgres    false    252    217                       2620    91250    likes create_like_notification    TRIGGER     �   CREATE TRIGGER create_like_notification AFTER INSERT ON public.likes FOR EACH ROW EXECUTE FUNCTION public.create_like_notification_trg();
 7   DROP TRIGGER create_like_notification ON public.likes;
       public          postgres    false    220    254                       2620    91254     posts create_repost_notification    TRIGGER     �   CREATE TRIGGER create_repost_notification AFTER INSERT ON public.posts FOR EACH ROW EXECUTE FUNCTION public.create_repost_notification_trg();
 9   DROP TRIGGER create_repost_notification ON public.posts;
       public          postgres    false    219    250                       2620    91274    posts repost_cant_be_reposted    TRIGGER     �   CREATE TRIGGER repost_cant_be_reposted BEFORE INSERT ON public.posts FOR EACH ROW EXECUTE FUNCTION public.repost_cant_be_reposted_trg();
 6   DROP TRIGGER repost_cant_be_reposted ON public.posts;
       public          postgres    false    253    219                       2620    115792    hashtags update_hashtag_count    TRIGGER     �   CREATE TRIGGER update_hashtag_count AFTER INSERT ON public.hashtags FOR EACH ROW EXECUTE FUNCTION public.cache_hashtag_count_trg();
 6   DROP TRIGGER update_hashtag_count ON public.hashtags;
       public          postgres    false    225    230                       2606    91082    blocks blocked_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocked_fkey FOREIGN KEY (blocked) REFERENCES public.users(id) ON DELETE CASCADE;
 =   ALTER TABLE ONLY public.blocks DROP CONSTRAINT blocked_fkey;
       public          postgres    false    3274    223    215                       2606    91077    blocks blocker_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocker_fkey FOREIGN KEY (blocker) REFERENCES public.users(id) ON DELETE CASCADE;
 =   ALTER TABLE ONLY public.blocks DROP CONSTRAINT blocker_fkey;
       public          postgres    false    3274    215    223                       2606    91100     bookmarks bookmarks_post_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.bookmarks DROP CONSTRAINT bookmarks_post_id_fkey;
       public          postgres    false    219    3291    221                       2606    91105     bookmarks bookmarks_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.bookmarks DROP CONSTRAINT bookmarks_user_id_fkey;
       public          postgres    false    3274    221    215            
           2606    91237    notifications comment_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT comment_id_fk FOREIGN KEY (comment_id) REFERENCES public.posts(id) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.notifications DROP CONSTRAINT comment_id_fk;
       public          postgres    false    3291    228    219            �           2606    115774    follows follows_followed_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_followed_fkey FOREIGN KEY (followed) REFERENCES public.users(id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.follows DROP CONSTRAINT follows_followed_fkey;
       public          postgres    false    215    217    3274            �           2606    115780    follows follows_follower_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_follower_fkey FOREIGN KEY (follower) REFERENCES public.users(id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.follows DROP CONSTRAINT follows_follower_fkey;
       public          postgres    false    215    217    3274                        2606    90975    likes likes_liker_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_liker_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 @   ALTER TABLE ONLY public.likes DROP CONSTRAINT likes_liker_fkey;
       public          postgres    false    220    215    3274                       2606    90980    likes likes_post_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;
 ?   ALTER TABLE ONLY public.likes DROP CONSTRAINT likes_post_fkey;
       public          postgres    false    219    3291    220                       2606    115786 (   password_changes passwordchanges_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.password_changes
    ADD CONSTRAINT passwordchanges_id_fkey FOREIGN KEY (id) REFERENCES public.users(id) ON DELETE CASCADE;
 R   ALTER TABLE ONLY public.password_changes DROP CONSTRAINT passwordchanges_id_fkey;
       public          postgres    false    3274    215    224            	           2606    91115    hashtags post_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.hashtags
    ADD CONSTRAINT post_id_fk FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;
 =   ALTER TABLE ONLY public.hashtags DROP CONSTRAINT post_id_fk;
       public          postgres    false    219    225    3291                       2606    91195    notifications post_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT post_id_fk FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.notifications DROP CONSTRAINT post_id_fk;
       public          postgres    false    3291    228    219                       2606    91065    views post_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.views
    ADD CONSTRAINT post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.views DROP CONSTRAINT post_id_fkey;
       public          postgres    false    219    222    3291            �           2606    99310    posts posts_publisher_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_publisher_fkey FOREIGN KEY (publisher) REFERENCES public.users(id) ON DELETE CASCADE;
 D   ALTER TABLE ONLY public.posts DROP CONSTRAINT posts_publisher_fkey;
       public          postgres    false    215    219    3274            �           2606    99315    posts posts_repost_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_repost_fkey FOREIGN KEY (repost) REFERENCES public.posts(id) ON DELETE CASCADE;
 A   ALTER TABLE ONLY public.posts DROP CONSTRAINT posts_repost_fkey;
       public          postgres    false    219    219    3291            �           2606    99346    posts replying_to_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT replying_to_fkey FOREIGN KEY (replying_to) REFERENCES public.posts(id) ON DELETE CASCADE;
 @   ALTER TABLE ONLY public.posts DROP CONSTRAINT replying_to_fkey;
       public          postgres    false    219    219    3291            �           2606    99325    posts replying_to_user_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT replying_to_user_fkey FOREIGN KEY (replying_to_user) REFERENCES public.users(id) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.posts DROP CONSTRAINT replying_to_user_fkey;
       public          postgres    false    215    3274    219                       2606    91190    notifications user_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.notifications DROP CONSTRAINT user_id_fk;
       public          postgres    false    215    228    3274                       2606    91060    views user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.views
    ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
 <   ALTER TABLE ONLY public.views DROP CONSTRAINT user_id_fkey;
       public          postgres    false    3274    222    215           