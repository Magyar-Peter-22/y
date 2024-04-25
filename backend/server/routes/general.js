import express from "express";
import bodyParser from "body-parser";

const router = express.Router();

router.get("/get_user", async (req, res) => {
    res.json({
        user: req.user,
        showStartMessage: req.session.showStartMessage,
        pending_registration: req.session.pending_registration
    });
});

export default router;