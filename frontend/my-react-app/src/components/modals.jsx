import React, { useState, useRef, useEffect } from "react";
import Stack from '@mui/material/Stack';
import SideMenu, { Inside } from "./side_menus.jsx";
import { TopMenu } from '/src/components/utilities';
import { SearchField } from "/src/components/inputs.jsx";
import { Backdrop, Box } from '@mui/material';
import { Typography } from '@mui/material';
import Fab from '@mui/material/Fab';
import { Icon } from '@mui/material';
import Avatar from '@mui/material/Avatar';
import { ThemeProvider } from '@mui/material';
import { ResponsiveSelector, ChooseChildBool, ProfileText, FadeLink, UserName, UserKey, noOverflow, DateLink, TextRow, ReplyingTo, GetUserName, GetUserKey, logo, creation, CenterLogo, FollowDialog } from '/src/components/utilities';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import { BoxList, BoxListOutlined, BlueTextButton } from '/src/components/containers';
import IconButton from '@mui/material/IconButton';
import Link from '@mui/material/Link';
import { ResponsiveButton, ButtonIcon, ButtonSvg, TabButton, PostButton, ProfileButton, TopMenuButton, CornerButton, WideButton, OutlinedButton } from "/src/components/buttons.jsx";
import { Grid } from '@mui/material';
import Divider from '@mui/material/Divider';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import { theme } from "/src/styles/mui/my_theme";
import { PlainTextField, PasswordFieldWithToggle } from "/src/components/inputs";
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { AdapterMoment } from '@mui/x-date-pickers/AdapterMoment';
import 'moment/locale/de';
import Checkbox from '@mui/material/Checkbox';
import FormGroup from '@mui/material/FormGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormControl from '@mui/material/FormControl';
import FormLabel from '@mui/material/FormLabel';
import ReCAPTCHA from 'react-google-recaptcha';
import axios from 'axios';
import { Endpoint, FormatAxiosError } from "/src/communication.js";
import { styled } from '@mui/material/styles';
import InputAdornment from '@mui/material/InputAdornment';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';

//creating modal data
let Modals = [];

function CreateModal(props) {
    const [modal, setModal] = React.useState();
    const [onClose, setonClose] = React.useState();

    function Show(content, onClose_) {
        setonClose(() => onClose_);
        setModal(content);
    }

    function Close() {
        if (onClose)
            onClose();
        setModal(undefined);
    }

    Modals[props.id] = {
        Close: Close,
        Show: Show
    }

    return (
        <Dialog open={Boolean(modal)} onClose={Close} >
            {modal}
        </Dialog>
    )
}

//creating modal elements
function CreateModals(props) {
    return (
        <>
            <CreateModal id={0} />
            <CreateModal id={1} />
            <ImagesModal />
        </>
    );
}

//specific modals

//error
function Error(err) {
    ErrorText(FormatAxiosError(err));
}

function ErrorText(text) {
    Modals[1].Show(<ErrorModal text={text} />);
}

function ErrorModal(props) {
    return (
        <GenericModal
            title={props.title ? props.title : "Error"}
            text={props.text}
            color="error"
        />
    );
}

function SuccessModal(props) {
    return (
        <GenericModal
            title={props.title ? props.title : "Success"}
            text={props.text}
            color="success.main"
        />
    );
}

function GenericModal(props) {
    const title = props.title;
    const text = props.text;
    return (
        <>
            {title &&
                <DialogTitle color={props.color}>
                    {title}
                </DialogTitle>
            }
            {text &&
                <DialogContent>
                    <DialogContentText>
                        {text}
                    </DialogContentText>
                </DialogContent>
            }
        </>
    );
}

//image
const ImagesDisplay = {};
function ImagesModal(props) {
    const [open, setOpen] = useState(false);
    const [index, setIndex] = useState(0);
    const imagesRef = useRef(null);
    const url = imagesRef.images ? imagesRef.images[index] : "";

    ImagesDisplay.Show = (images, imageIndex) => {
        try {
            imagesRef.images = images;
            setOpen(true);
            setIndex(imageIndex);
        }
        catch (err) {
            Error(err);
        }
    };

    function Close() {
        setOpen(false);
    }

    function Step(steps, event) {
        event.stopPropagation();
        setIndex((prev) => {
            let index_ = prev + steps;
            const length = imagesRef.images.length;
            if (index_ < 0)
                index_ += length;
            else if (index_ >= length)
                index_ -= length;
            return index_;
        });
    }

    const image = (
        <div style={{ flexGrow: 1, height: "100%", width: "100%", backgroundImage: "url(" + url + ")", backgroundRepeat: "no-repeat", backgroundPosition: "center", backgroundSize: "contain" }} />
    );

    return (
        <Backdrop open={open} onClick={Close} style={{ zIndex: 1 }}>
            <ResponsiveSelector breakpoint="md">
                <Stack direction="row" style={{ height: "80%", width: "80%", alignItems: "center", justifyContent: "center" }}>
                    <StepButton icon="arrow_left" tall={true} onClick={(e) => { Step(-1, e); }} />
                    {image}
                    <StepButton icon="arrow_right" tall={true} onClick={(e) => { Step(1, e); }} />
                </Stack>

                <Stack direction="column" style={{ height: "80%", width: "95%", alignItems: "center", justifyContent: "center" }}>
                    {image}
                    <Stack direction="row" style={{ width: "100%" }}>
                        <StepButton icon="arrow_left" onClick={(e) => { Step(-1, e); }} />
                        <StepButton icon="arrow_right" onClick={(e) => { Step(1, e); }} />
                    </Stack>
                </Stack>
            </ResponsiveSelector>
        </Backdrop>
    );
}

function StepButton(props) {
    return (
        <Box sx={{
            display: "flex", width: props.tall ? "50px" : "100%", height: props.tall ? "100%" : "50px", justifyContent: "center", alignItems: "center",
            fontSize: "50px", "&:hover": { fontSize: "75px" }
        }}
            onClick={props.onClick}>
            <Icon sx={{ color: "primary.contrastText", fontSize: "inherit" }}>
                {props.icon}
            </Icon>
        </Box >
    );
}

function ShowImage(images, imageIndex) {
    ImagesDisplay.Show(images, imageIndex);
}

export { ErrorModal, Modals, ImagesDisplay, CreateModals, Error, ErrorText, ShowImage,SuccessModal };