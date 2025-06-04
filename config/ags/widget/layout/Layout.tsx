import { App, Astal, Gdk, Gtk } from "astal/gtk3"
import { Variable, bind } from "astal"

function PopUp(){
    const status = Variable(true)
    return <box>
        caps is {bind(status).as
        (status => status ? "enabled":"not enabled")}
    </box>
}

export default function Layout(monitor: Gdk.Monitor){
    return (
        <window
            gdkmonitor={monitor}
            className="LayoutStatus"
            namespace="layoutstatus"
            application={App}
            layer={Astal.Layer.OVERLAY}
            keymode={Astal.Keymode.ON_DEMAND}
            anchor={Astal.WindowAnchor.TOP}
        >
            <eventbox>
                <PopUp />
            </eventbox>
        </window>
    )
};
