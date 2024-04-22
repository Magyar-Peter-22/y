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
import { Validator } from "node-input-validator";
import * as g from "./global.js";

import initialize_app from "./components/app_use.js";
initialize_app();
import initialize_passport,{router as passport_routes}  from "./components/passport.js";
initialize_passport();

//routes
import general from "./routes/general.js";
g.app.use('/', general);

import register from "./routes/register.js";
g.app.use('/', register);

import user from "./routes/user.js";
g.app.use("/user", user);

import member from "./routes/logged_in.js";
g.app.use("/member", member);

g.app.use("/",passport_routes);

const port = g.config.port;
g.app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});