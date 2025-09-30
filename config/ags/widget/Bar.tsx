import { App } from "astal/gtk3"
import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import { subprocess, exec, execAsync } from "astal/process"
import { ButtonProps } from "astal/gtk4/widget";

import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Battery from "gi://AstalBattery"
import Wp from "gi://AstalWp"
import Network from "gi://AstalNetwork"
import Tray from "gi://AstalTray"

function SysTray() {
    const tray = Tray.get_default()

    return <box className="SysTray">
        {bind(tray, "items").as(items => items.map(item => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                menuModel={bind(item, "menuModel")}>
                <icon gicon={bind(item, "gicon")} />
            </menubutton>
        )))}
    </box>
}

function Wifi() {
    const network = Network.get_default()
    const wifi = bind(network, "wifi")

    return <box className="Network" visible={wifi.as(Boolean)}>
        {wifi.as(wifi => wifi && (
        <label
            label={bind(wifi, "ssid").as(String)}
        />))}
        {wifi.as(wifi => wifi && (
            <icon
                className="Wifi"
                icon={bind(wifi, "iconName")}
            />))}
    </box>

}

function BatteryLevel() {
    const bat = Battery.get_default()

    return <box className="Battery"
        visible={bind(bat, "isPresent")}>
        <icon icon={bind(bat, "batteryIconName")} />
        <label label={bind(bat, "percentage").as(p =>
            `${Math.floor(p * 100)}%`
        )} />
    </box>
}

function toWord(num) {
    switch(num){
        case 1: return "one"
        case 2: return "two"
        case 3: return "three"
        case 4: return "four"
        case 5: return "five"
        case 6: return "six"
        case 7: return "seven"
        case 8: return "eight"
        case 9: return "nine"
        case 10: return "ten"
        default: return num
    }
}

type WsButtonProps = ButtonProps & {
    ws: Hyprland.Workspace;
};

function WorkspaceButton({ ws, ...props }: WsButtonProps) {
    const hypr = Hyprland.get_default();
    const urgent = Variable(-1);
    const className = Variable.derive(
        [bind(hypr, "focusedWorkspace"), bind(hypr, "clients"), bind(urgent)],
        (fws, _, uws) => {
            let name = "empty";
            if(ws.id == fws.id){
                name = "focused";
                urgent.set(-1);
            }
            else if(ws.id == uws){
                name = "urgent";
            }
            else if(hypr.get_workspace(ws.id)?.get_clients().length > 0){
                name = "active";
            }
            return name;
        },
    );
    // detect urgent workspaces
    hypr.connect("event", (_, event, data) => {
        if(event === "urgent"){
            const client = hypr.get_client(data)
            if (!client) return

            const wsId = client.workspace.id
            const currentWs = hypr.focusedWorkspace.id

            if (wsId !== currentWs) {
                urgent.set(wsId)
            }
        }
    });

    return <button
        className={bind(className).as(String)}
        onDestroy={() => classNames.drop()}
        onClicked={() => ws.focus()}>
        {toWord(ws.id)}
    </button>;
};


function Workspaces() { 
    return (
        <box className="Workspaces">
          {[0,1,2,3,4,5,6,7,8,9].map((i) => (
            <WorkspaceButton ws={Hyprland.Workspace.dummy(i + 1, null)} />
          ))}
        </box> );
}

function FocusedClient() {
    const hypr = Hyprland.get_default();
    const focused = bind(hypr, "focusedClient");

    function maxWidth(title, width){
        if(title.length < width){
            return title
        }
        else{
            return title.slice(0, width) + "..."
        }
    }

    return <box
        className="Focused"
        visible={focused.as(Boolean)}>
        {focused.as(client => (
            client && <label 
                label={bind(client, "title")
                    .as(title => title ? maxWidth(title, 70) : "")} // width of focused client chars
            />
        ))}
    </box>
}

function Time({ format = " %H:%M %m-%d " }) {
    const time = Variable<string>("").poll(1000, () =>
        GLib.DateTime.new_now_local().format(format)!);

    return <label
        className="Time"
        onDestroy={() => time.drop()}
        label={time()}
    />
}

function Language() {
    const hypr = Hyprland.get_default();
    const layout = Variable("Na");

    function shorten(text){
        switch(text){
            case("English (US)"):
                return "en";
                break;
            case("Russian"):
                return "ru";
                break;
            case("Kazakh"):
                return "kz";
                break;
            default:
                return text;
                break;
            // TODO: make detection of language at startup
        }
    }

    hypr.connect("keyboard-layout", 
        (_self, _keyboard, _layout) => {layout.set(_layout);})

    return <box className="Language">
        <label label={bind(layout).as(shorten)}/>
    </box>
}


function Audio() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    const out = function(){
        try {
             exec(["bash", "-c", "hyprctl dispatch exec pavucontrol"])
        }
        catch (err) {
            return null
        }
    };
    return <box className="Audio">
        <icon icon={bind(speaker, "volumeIcon")} />
        <button onClicked={out}>
            {bind(speaker, "volume")
                .as(vol => `${Math.floor(vol * 100)}%`)}  
        </button>
    </box>
}
// TODO: Bluetooth headphones


export default function Bar(monitor: Gdk.Monitor) {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={BOTTOM | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <Workspaces />
            </box>
            <box>
                <FocusedClient />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <Wifi />
                <Audio />
                <BatteryLevel />
                <SysTray />
                <Language />
                <Time />
            </box>
        </centerbox>
    </window>
}
