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
import { postQuery, post_list } from "./general.js";

const router = express.Router();

router.post("/get_posts", async (req, res, next) => {
    await post_list(req, res, next, undefined, undefined, " WHERE post.replying_to IS NULL");
});
router.post("/get_followed_posts", async (req, res, next) => {
    await post_list(req, res, next, undefined, undefined, " WHERE post.replying_to IS NULL AND post.publisher=ANY(SELECT follows.followed from follows WHERE follows.follower=:user_id)");
});


export default router;