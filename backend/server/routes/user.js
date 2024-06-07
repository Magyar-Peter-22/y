import express from "express";
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
import { Validator } from "node-input-validator";
import { CheckV } from "../components/validations.js";
import * as g from "../global.js";
import * as pp from "../components/passport.js";
import change_password from "./change_password.js";

const router = express.Router();

router.use("/change_password", change_password);

router.post('/exists/email', async (req, res) => {
    const v = new Validator(req.body, {
        email: 'required|email',
    });
        await CheckV(v);

    const { email } = req.body;
    const exists = await exists_email(email);
    res.send(exists);
});

async function exists_email(email)
{
    const result = await db.query(named("SELECT count(*) FROM users WHERE email=:email")({ email: email.toLowerCase() }));
    const exists = result.rows[0].count > 0;
    return exists;
}

router.post('/exists/username', async (req, res) => {
    const v = new Validator(req.body, {
        username: 'required|email',
    });
    await CheckV(v);

    const { username } = req.body;
    res.send(username_exists(username));
});

async function username_exists(username) {
    const result = await db.query(named("SELECT count(*) FROM users WHERE username=:username")({ username: username }));
    return result.rows[0].count > 0;
}

async function selectable_username(new_username, current_username) {
    const exists = await username_exists(new_username);
    return (!exists || new_username === current_username);
}

export default router;
export { username_exists, selectable_username,exists_email };