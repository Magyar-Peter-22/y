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
import { CheckV, CheckErr, validate_image } from "../../components/validations.js";
import { ApplySqlToUser, UpdateUser } from "../logged_in.js";

const router = express.Router();

router.post("/post", async (req, res) => {
    const v = new Validator(req.body, {
        text: "required|string|maxLength:5",
    });
    await CheckV(v);

    const files = tryGetFiles(req,"images");
    if (files !== undefined)
        files.forEach(file => {
            validate_image(file);
        });

    const { text } = req.body;
    const result = await db.query(named("INSERT INTO posts (publisher,text,image_count) VALUES (:user_id, :text,:image_count) RETURNING id")({ user_id: req.user.id, text: text, image_count: files ? files.length : 0 }))
    const post_id = result.rows[0].id;

    if (files !== undefined)
        files.forEach((file, index) => {
            file.mv(config.__dirname + "/public/images/posts/" + post_id + "_" + index + ".jpg");
        });

    res.sendStatus(200);
});

function tryGetFiles(req, fileName) {
    if (req.files) {
        const target = req.files[fileName];
        if (target !== undefined && !Array.isArray(target))
            return [target];
        else
            return target;
    }
    return undefined;
}

export default router;