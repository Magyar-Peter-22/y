import env from "dotenv";
import express from "express";
import nodemailer from "nodemailer";
import { dirname } from "path";
import pg from "pg";
import { fileURLToPath } from "url";
import yesql from 'yesql';
const named = yesql.pg;
env.config();

const app = express();

//media types

const types = {
    accepted_image_types: ["image/png", "image/jpeg", "image/jpg"],
    accepted_video_types: ["video/mp4"]
};
types.accepted_media_types = [...types.accepted_image_types, ...types.accepted_video_types];

//config

const config = {
    port: 3001,
    saltRounds: 10,
    __dirname: dirname(fileURLToPath(import.meta.url)),
    google_rechapta_secret_key: process.env.GOOGLE_RECHAPTA_SECRET,
    cookie_remember: 1000 * 60 * 60 * 24 * 30,//1 month. 
    cookie_registering: 1000 * 60 * 60 * 2,//2 hours. the email, name, ect. the user sends at the start of the registration must be finalized within this time
    address_mode: {
        server: process.env.SERVER_URL,
        client: process.env.CLIENT_URL,
    },
    posts_per_request: 30,
    users_per_request: 60,
    trends_per_request: 60,
    notifications_per_request: 60,
    uploadLimitMB: 100,
    extra_debug:process.env.EXTRA_DEBUG,
    fast_register:process.env.FAST_REGISTER,
    ...types
}

//nodemailer

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL,
        pass: process.env.EMAIL_PASSWORD
    }
});

//pg
//use url if available, then object
const poolConfig=process.env.POSTGRES_URL?{connectionString: process.env.POSTGRES_URL}:
{
    user: process.env.POSTGRES_USER,
    host: process.env.POSTGRES_HOST,
    database: process.env.POSTGRES_DATABASE,
    password: process.env.POSTGRES_PASSWORD,
    port: process.env.POSTGRES_PORT,
};

const pgPool = new pg.Pool(poolConfig);

async function initialize() {
    const db = pgPool;
    await db.connect((err)=>{
        if(err)
        {
            console.log("\n\nFailed to connect to DB\n\n");
            throw(err);
        }
        console.log("DB connected successfully");
    });
    global.db = db;
}

//global

global.app = app;
global.config = config;
global.UserId = (req) => req.user.id;
global.named = named;

export { initialize, pgPool, transporter };
