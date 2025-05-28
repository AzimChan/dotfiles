import { App } from "astal/gtk3"
import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
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

    return <box visible={wifi.as(Boolean)}>
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
function Workspaces() { 

    const hypr = Hyprland.get_default()

    const labels=[
        "one", "two", "three", "four", "five",
        "six", "seven", "eight", "nine", "ten"
    ]

    const render = function(activeWorkspaces){
        const active = activeWorkspaces
            .filter(ws => !(ws.id >= -99 && ws.id <= -2))
            .sort((a, b) => a.id - b.id)
            .map(ws => (toWord(ws.id)));
        
        return <box className="Workspaces">
            {labels.map((label, index) => (
                <button
                    className={active.includes(label) ? (
                        bind(hypr, "focusedWorkspace").as(fw => 
                        toWord(fw.id) === label ? "focused" :"active") 
                    ) : "empty"}
                    onClicked={() => 
                        hypr.get_workspace(index+1).focus()}>
                    {label}
                </button>
            ))}
        </box>
    }

    return bind(hypr, "workspaces").as(render)
}

function FocusedClient() {
    const hypr = Hyprland.get_default();
    const focused = bind(hypr, "focusedClient");

    return <box
        className="Focused"
        visible={focused.as(Boolean)}>
        {focused.as(client => (
            client && <label 
                label={bind(client, "title").as(String)} 
                maxWidthChars={1}
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
    const layout = Variable("English");
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
                return "00"
                break;
            // TODO: make detection of language at startup
        }
    }

    hypr.connect("keyboard-layout", (_self, _keyboard, _layout) => {layout.set(_layout);})
    return <box className="Language">
        <label label={bind(layout).as(shorten)}/>
    </box>
}

export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <Workspaces />
            </box>
            <box>
                <FocusedClient />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <Wifi />
                <BatteryLevel />
                <SysTray />
                <Language />
                <Time />
            </box>
        </centerbox>
    </window>
}
// TODO: Volume, Wifi name, Memory, Language, Padding
