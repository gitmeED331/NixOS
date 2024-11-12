/**
 * MIT License
 *
 * Copyright (c) 2024 TopsyKrets
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction...
 *
 */

import { Astal, Gtk, Gdk, App } from "astal/gtk4";
import { Variable, bind, GLib } from "astal";

import Icon from "../lib/icons";
import powerProfiles from "gi://AstalPowerProfiles";
import Battery from "gi://AstalBattery";

const battery = Battery.get_default();
const PowerProfiles = powerProfiles.get_default();
const percentage = bind(battery, "percentage");
const charging = bind(battery, "charging");

const chargeTooltip = () => (charging.get() ? "Charging" : "Discharging");

const chargeIcon = () => (charging.get() ? Icon.battery.Charging : Icon.battery.Discharging);

const ChargeIndicatorIcon = () => {
	return <icon cssClasses={bind(battery, "charging").as((c) => (c === true ? "charging" : "discharging"))} tooltipText={charging.as(chargeTooltip)} icon={charging.as(chargeIcon)} />;
};

const PercentageReveal = Variable(true);

const TheLabelReveal = () => {
	const PercentLabel = <label label={bind(battery, "percentage").as((p) => `${p * 100}%`)} tooltipText={bind(battery, "charging").as(chargeTooltip)} />;
	return (
		<revealer transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT} transitionDuration={300} revealChild={bind(battery, "charging").as((c) => (c ? false : true))}>
			{PercentLabel}
		</revealer>
	);
};

const BatteryLevelBar = ({ blocks = 10 }) => (
	<levelbar
		orientation={Gtk.Orientation.HORIZONTAL}
		max_value={blocks}
		mode={Gtk.LevelBarMode.CONTINUOUS}
		tooltipText={bind(PowerProfiles, "active_profile")}
		value={percentage.as((p) => p * blocks)}
	/>
);

function BatteryButton() {
	const batteryButtoncssClasses = () => {
		const classes = [];

		if (percentage.get() <= 0.3) {
			classes.push("low");
		}
		if (charging.get()) {
			classes.push("charging");
		} else {
			classes.push("discharging");
		}
		classes.push("battery");

		return classes.join(" ");
	};

	return (
		<button
			cssClasses={batteryButtoncssClasses()}
			visible={true}
			onClicked={(button, event) => {
				if (event.get_button() === Gdk.BUTTON_PRIMARY) {
					const win = App.get_window("sessioncontrols");
					if (win) {
						win.visible = !win.visible;
					}
				}
				if (event.get_button() === Gdk.BUTTON_SECONDARY) {
					PercentageReveal.set(!PercentageReveal.get());
				}
			}}
		>
			<box spacing={3} valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
				<TheLabelReveal />
				<ChargeIndicatorIcon />
				<BatteryLevelBar />
			</box>
		</button>
	);
}

export default BatteryButton;