import Badge from '@mui/material/Badge';
import { styled } from '@mui/material/styles';
import { useState } from "react";
import config from "/src/components/config.js";
import { ListenToStream } from "/src/components/event_stream";

function GetNotificationCount() {
    const [count, setCount] = useState(0);
    ListenToStream(config.address_mode.server+"/member/notifications/events", (data) => {
        setCount(data);
    });
    return [count, setCount];
}

function DisplayNotificationCount({ children }) {
    const [count, setCount] = GetNotificationCount();

    function clear() {
        setCount(0);
    }

    return (
        <StyledBadge color="primary" badgeContent={count} max={99} invisible={count == 0} onClick={clear}>
            {children}
        </StyledBadge>
    );
}

const StyledBadge = styled(Badge)(({ theme }) => ({
    '& .MuiBadge-badge': {
        right: 15,
        top: 10,
    },
}));

export { DisplayNotificationCount };
