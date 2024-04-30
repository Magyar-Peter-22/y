import React, { useState, useEffect } from 'react';
import { theme } from '/src/styles/mui/my_theme.jsx';
import Stack from '@mui/material/Stack';
import SideMenu, { Inside } from "/src/components/side_menus.jsx";
import { SearchField } from "/src/components/inputs.jsx";
import { Box } from '@mui/material';
import { Typography } from '@mui/material';
import Fab from '@mui/material/Fab';
import { Icon } from '@mui/material';
import Avatar from '@mui/material/Avatar';
import { ThemeProvider } from '@mui/material';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import { BoxList, BoxListOutlined, BlueTextButton } from '/src/components/containers';
import IconButton from '@mui/material/IconButton';
import Link from '@mui/material/Link';
import { ResponsiveButton, ButtonIcon, ButtonSvg, TabButton, PostButton, ProfileButton, TopMenuButton } from "/src/components/buttons.jsx";
import Moment from "moment";
import { Endpoint, FormatAxiosError } from "/src/communication.js";
import { UserData } from "/src/App.jsx";
import { Error, Modals } from "/src/components/modals";
import axios from 'axios';
import Tooltip from '@mui/material/Tooltip';

const noOverflow = {
    whiteSpace: 'nowrap',
    overflow: "hidden",
    textOverflow: 'ellipsis',
    display: "block"
};

const logo = "/svg/y.svg";

const creation = "© 2024 Y Corp.";

const default_profile = "/images/default_profile.jpg";

const default_image = "/images/example profile copy.jpg";

function ResponsiveSelector(props) {
    let isBig = props.override === undefined ? AboveBreakpoint(props.breakpoint) : props.override;
    return (<ChooseChildBool first={isBig}>{props.children}</ChooseChildBool>);
}

function AboveBreakpoint(breakpoint) {
    const [screenWidth, setScreenWidth] = useState(window.innerWidth);

    useEffect(() => {
        const handleResize = () => {
            setScreenWidth(window.innerWidth);
        };

        window.addEventListener('resize', handleResize);

        // Cleanup function to remove event listener
        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);

    return screenWidth > theme.breakpoints.values[breakpoint];
}


function ChooseChild(props) {
    if (props.children.length !== undefined) {
        let chosenChild = props.children.length > props.index ? props.index : 0;
        return props.children[chosenChild];
    }
    else {
        return props.children;
    }
}

function TopMenu(props) {
    return (
        <div style={{ height: "40px", position: "static" }}>
            {props.children}
        </div>);
}

function ChooseChildBool(props) {
    return (<ChooseChild index={props.first ? 0 : 1}>{props.children}</ChooseChild>);
}

function ProfileText(props) {
    return (
        <div style={{ flexGrow: 1, overflow: "hidden" }}>
            <Stack direction={props.row ? "row" : "column"} spacing={props.row ? 0.5 : 0}>
                {props.link ? <UserLink user={props.user} /> : <UserName user={props.user} />}
                <UserKey user={props.user} />
            </Stack>
        </div>
    );
}

function UserName(props) {
    return (
        <Typography variant="small_bold" align="left" style={noOverflow}>
            <GetUserName user={props.user} />
        </Typography>
    );
}

function UserLink(props) {
    return (
        <Link typography="small_bold" href="#" align="left" style={noOverflow} {...props}>
            <GetUserName user={props.user} />
        </Link>
    );
}

function UserKeyLink(props) {
    return (
        <Link typography="small" href="#" align="left" style={noOverflow} {...props}>
            <GetUserKey user={props.user} />
        </Link>
    );
}

function GetUserName(props) {
    return props.user ? props.user.name : "name";
}
function GetUserKey(props) {
    return props.user ? "@" + props.user.username : "@username";
}

function UserKey(props) {
    return (
        <Typography variant="small_fade" align="left" fontWeight="normal" style={noOverflow} >
            <GetUserKey user={props.user} />
        </Typography>
    );
}


function FadeLink(props) {
    return (
        <Link typography="small_fade" {...props}>{props.children}</Link>
    );
}

function BoldLink(props) {
    return (
        <Link typography="small_bold" {...props}>{props.children}</Link>
    );
}

function TabSwitcher(props) {
    const [getTab, setTab] = React.useState(props.tabs[0].text);

    function SelectTab(tabName) {
        setTab(tabName);
    }

    const selectedTab = props.tabs.find((tab) => { return tab.text === getTab });

    return (
        <>
            <TopMenu>
                <Box sx={{ borderBottom: 1, borderColor: 'divider', height: "100%", width: "100%", display: "flex", alignItems: "center", flexDirection: "row" }}>
                    {props.tabs.map((tab, index) => {
                        return (
                            <TopMenuButton
                                selected={getTab === tab.text ? true : false}
                                onClick={() => {
                                    SelectTab(tab.text)
                                }}
                                key={index}>
                                {tab.text}
                            </TopMenuButton>);
                    })}
                    {props.children}
                </Box>
            </TopMenu>
            {selectedTab.contents}
        </>
    );
}

function DateLink(props) {
    const moment = Moment(new Date(props.isoString));
    const hover = moment.format('h:mm a [·] MM DD YYYY');
    let display;
     if (props.passed) {
        const passed = Moment.duration(Moment().diff(moment));
        if (passed.asSeconds() < 60)
            display = Math.round(passed.asSeconds()) + "s";
        else if (passed.asMinutes() < 60)
            display = Math.round(passed.asMinutes()) + "m";
        else if (passed.asHours() < 24)
            display = Math.round(passed.asHours()) + "h";
        else if (passed.asDays() < 7)
            display = Math.round(passed.asDays()) + "d";
        else display= moment.format('MMM DD');
    }
    else
        display = hover;

    return (
        <Tooltip title={hover}>
            <div>
                <FadeLink style={{ flexShrink: 0, ...noOverflow }}>
                    {display}
                </FadeLink>
            </div>
        </Tooltip>
    );
}

function TextRow(props) {
    return (
        <Stack direction="row" spacing={0.5} style={{ overflow: "hidden" }}>
            {props.children}
        </Stack>
    );
}

function ReplyingTo(props) {
    return (
        <TextRow >
            <Typography variant="small_fade" style={{ flexShrink: 0, ...noOverflow }}>Replying to</Typography>
            <UserKeyLink />
        </TextRow>
    );
}

function ToCorner(props) {
    const offset = "10px";
    const style = { position: "absolute" };
    if (props.left)
        style.right = offset;
    else
        style.left = offset;
    if (props.down)
        style.down = offset;
    else
        style.top = offset;
    return (<div size="small" style={style}>
        {props.children}
    </div>);
}

function CenterLogo() {
    return (
        <img src={logo} style={{ height: "30px", marginTop: "10px" }} />
    );
}


function FollowDialog(props) {
    return (
        <ListItem disablePadding>
            <ListItemButton>
                <Stack direction="row" spacing={1} sx={{ alignItems: "center", width: "100%" }}>
                    <Avatar />
                    <ProfileText user={props.user} />
                    <FollowButton user_id={props.user.id} />
                </Stack>
            </ListItemButton>
        </ListItem>
    );
}

function FollowButton(props) {
    const [following, setFollowing] = useState(false);
    async function toggleFollow() {
        setFollowing((prev) => {
            return !prev;
        });
        await axios.post(Endpoint("/member/follow_user"),
            {
                id: props.user_id,
                set: following
            }
        );
    }
    return (
        <Fab onClick={toggleFollow} variant="extended" size="small" color="black" sx={{ flexShrink: 0 }}>{following ? "Following" : "Follow"}</Fab>
    );
}

function GetProfilePicture(user) {
    return (user ? Endpoint("/images/profiles/" + user.id + ".jpg") : default_profile);
}


export { AboveBreakpoint, ResponsiveSelector, ChooseChild, ChooseChildBool, TopMenu, ProfileText, FadeLink, TabSwitcher, UserName, UserKey, noOverflow, BoldLink, UserLink, DateLink, TextRow, UserKeyLink, ReplyingTo, GetUserName, GetUserKey, logo, creation, ToCorner, CenterLogo, default_profile, FollowDialog, GetProfilePicture, default_image,FollowButton }