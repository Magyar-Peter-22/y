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
import * as g from "../../global.js";
import * as pp from "../../components/passport.js";
import { username_exists, selectable_username } from "../user.js";
import { Validator } from "node-input-validator";
import { CheckV, CheckErr, validate_image } from "../../components/validations.js";
import { postQuery, post_list } from "./general.js";
import  notifications_query from "./notifications_query.js";

const router = express.Router();
router.post("/get", async (req, res) => {
	const v = new Validator(req.body, {
		from: 'required|integer'
	});
	await CheckV(v);
	const { from } = req.body;
	const other_notifications = await db.query(named(notifications_query)({ user_id: req.user.id, from: from }));
	res.send(other_notifications.rows);
});

export default router;