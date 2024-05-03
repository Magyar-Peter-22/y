import express from "express";
import bodyParser from "body-parser";
import pg from "pg";
import bcrypt from "bcrypt";
import passport from "passport";
import { Strategy } from "passport-local";
import GoogleStrategy from "passport-google-oauth2";
import session from "express-session";
import ConnectPg from 'connect-pg-simple';
import env from "dotenv";
import { dirname } from "path";
import { fileURLToPath } from "url";
import *  as url from "url";
import path from "path";
import fileUpload from "express-fileupload";
import fs from "fs";
import yesql from 'yesql';
const named = yesql.pg;
import cors from "cors";
import axios from "axios";
import nodemailer from "nodemailer";
import * as g from "../../global.js";
import * as pp from "../../components/passport.js";
import { username_exists, selectable_username } from "../user.js";
import { Validator } from "node-input-validator";
import { CheckV, CheckErr,validate_image } from "../../components/validations.js";
import { ApplySqlToUser,UpdateUser } from "../logged_in.js";

const router = express.Router();

router.post("/update_profile_picture", async (req, res) => {
    const file = req.files.image;
    validate_image(file);

    file.mv(config.__dirname + "/public/images/profiles/" + req.user.id + ".jpg");
    res.sendStatus(200);
});

router.get("/close_starting_message", async (req, res) => {
    req.session.showStartMessage = false;
    res.sendStatus(200);
});

router.post("/change_username", async (req, res) => {
    const v = new Validator(req.body, {
        username: 'required|username',
    });
    await CheckV(v);

    const { username } = req.body;

    const selectable = await selectable_username(username, req.user.username);
    if (!selectable)
        CheckErr("this username is not available");

    const result = await db.query(named("UPDATE users SET username=:username WHERE id=:id RETURNING *")({ username: username, id: req.user.id }));
    await ApplySqlToUser(result, req);
    res.sendStatus(200);
});

router.post('/ok_username', async (req, res) => {
    if (pp.auth(req, res)) {

        const v = new Validator(req.body, {
            username: 'required|username',
        });
        const matched = await v.check();
        if (!matched)
            return res.send(false);;

        const { username } = req.body;
        const selectable = await selectable_username(username, req.user.username);
        res.send(selectable);
    }
});

router.post("/change_browser_notifications", async (req, res) => {
    const v = new Validator(req.body, {
        enabled: 'required|boolean',
    });
    await CheckV(v);

    const result = await db.query(named("UPDATE users SET browser_notifications=:enabled WHERE id=:id RETURNING *")({ enabled: req.body.enabled, id: req.user.id }));
    await ApplySqlToUser(result, req);
    res.sendStatus(200);
});

export default router;