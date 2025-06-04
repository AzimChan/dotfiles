import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/Bar"
import OSD from "./widget/osd/OSD"
import LayoutStatus from "./widget/layout/Layout"
App.start({
    css: style,
    main() {
        App.get_monitors().map(Bar)
        App.get_monitors().map(OSD)
        /*App.get_monitors().map(LayoutStatus)*/ //deprecated for now
    },
})
