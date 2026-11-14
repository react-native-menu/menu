import * as React from "react";
import {
	Button,
	Platform,
	Pressable,
	StyleSheet,
	Text,
	View,
} from "react-native";
import { MenuView, type MenuComponentRef } from "@react-native-menu/menu";
import { useRef } from "react";

export const App = () => {
	const [themeVariant] = React.useState<string | undefined>("light");
	const menuRef = useRef<MenuComponentRef>(null);
	const [taps, setTaps] = React.useState(0);
	const [linkTaps, setLinkTaps] = React.useState(0);

	return (
		<View style={styles.container}>
			<MenuView
				title="Long press menu"
				shouldOpenOnLongPress
				onPressAction={({ nativeEvent }) => {
					console.warn(JSON.stringify(nativeEvent));
				}}
				actions={[
					{ id: "copy", title: "Copy" },
					{ id: "share", title: "Share" },
				]}
				testID="longPressMenuView"
			>
				<View style={styles.card}>
					<Text>
						Long press opens the menu. A tap reaches the children:{" "}
						<Text
							style={styles.link}
							onPress={() => setLinkTaps((n) => n + 1)}
							accessibilityRole="link"
						>
							link ({linkTaps})
						</Text>
					</Text>
					<Pressable
						style={styles.counter}
						onPress={() => setTaps((n) => n + 1)}
						accessibilityRole="button"
						testID="longPressMenuCounter"
					>
						<Text>Tapped {taps} times</Text>
					</Pressable>
				</View>
			</MenuView>
			<Button
				title="Show Menu with ref (Android only)"
				onPress={() => menuRef.current?.show()}
			/>
			<MenuView
				ref={menuRef}
				title="Menu Title"
				onPressAction={({ nativeEvent }) => {
					console.warn(JSON.stringify(nativeEvent));
				}}
				actions={[
					{
						id: "add",
						title: "Add to List",
						titleColor: "#2367A2",
						image: Platform.select({
							ios: "plus",
							android: "ic_menu_add",
						}),
						imageColor: "#2367A2",
						subactions: [
							{
								id: "nested1",
								title: "Nested action",
								titleColor: "rgba(250,180,100,0.5)",
								subtitle: "State is mixed",
								image: Platform.select({
									ios: "heart.fill",
									android: "ic_menu_today",
								}),
								imageColor: "rgba(100,200,250,0.3)",
								state: "mixed",
							},
							{
								id: "nestedDestructive",
								title: "Destructive Action",
								attributes: {
									destructive: true,
								},
								image: Platform.select({
									ios: "trash",
									android: "ic_menu_delete",
								}),
							},
						],
					},
					{
						id: "share",
						title: "Share Action",
						titleColor: "#46F289",
						subtitle: "Share action on SNS",
						image: Platform.select({
							ios: "square.and.arrow.up",
							android: "ic_menu_share",
						}),
						imageColor: "#46F289",
						state: "on",
					},
					{
						id: "mixed",
						title: "Mixed State",
						titleColor: "rgba(100,200,250,0.3)",
						subtitle: "State is mixed",
						image: Platform.select({
							ios: "heart.fill",
							android: "ic_menu_today",
						}),
						imageColor: "rgba(100,200,250,0.3)",
						state: "mixed",
						subactions: [
							{
								id: "nested2",
								title: "Nested action",
								titleColor: "rgba(250,180,100,0.5)",
								subtitle: "State is mixed",
								image: Platform.select({
									ios: "tray",
									android: "ic_menu_agenda",
								}),
								imageColor: "rgba(100,200,250,0.3)",
								state: "mixed",
							},
							{
								id: "nestedMixed",
								title: "Mixed State",
								subtitle: "State is mixed",
								image: Platform.select({
									ios: "heart.fill",
									android: "ic_menu_today",
								}),
								imageColor: "#46F289",
								subactions: [
									{
										id: "nestednesteddisabled",
										title: "Disabled Action",
										subtitle: "Action is disabled",
										attributes: {
											disabled: true,
										},
										image: Platform.select({
											ios: "tray",
											android: "ic_menu_agenda",
										}),
									},
									{
										id: "nestednestedhidden",
										title: "Hidden Action",
										subtitle: "Action is hidden",
										attributes: {
											hidden: true,
										},
									},
									{
										id: "nestednesteddestructive",
										title: "Destructive Action",
										attributes: {
											destructive: true,
										},
										image: Platform.select({
											ios: "trash",
											android: "ic_menu_delete",
										}),
									},
								],
							},
						],
					},
					{
						id: "disabled",
						title: "Disabled Action",
						subtitle: "Action is disabled",
						attributes: {
							disabled: true,
						},
						image: Platform.select({
							ios: "tray",
							android: "ic_menu_agenda",
						}),
					},
					{
						id: "hidden",
						title: "Hidden Action",
						subtitle: "Action is hidden",
						attributes: {
							hidden: true,
						},
					},
					{
						id: "destructive",
						title: "Destructive Action",
						attributes: {
							destructive: true,
						},
						image: Platform.select({
							ios: "trash",
							android: "ic_menu_delete",
						}),
					},
				]}
				themeVariant={themeVariant}
				testID="menuView"
			>
				<View style={styles.button}>
					<Text style={styles.buttonText}>Test</Text>
				</View>
			</MenuView>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		flex: 1,
		alignItems: "center",
		justifyContent: "center",
		gap: 10,
	},
	button: {
		height: 100,
		width: 100,
		backgroundColor: "red",
		borderRadius: 50,
		justifyContent: "center",
		alignItems: "center",
	},
	buttonText: { color: "white" },
	card: {
		width: 280,
		padding: 16,
		gap: 12,
		borderRadius: 16,
		backgroundColor: "#EEF1F5",
	},
	link: { color: "#2367A2", fontWeight: "600" },
	counter: {
		alignSelf: "flex-start",
		paddingHorizontal: 12,
		paddingVertical: 8,
		borderRadius: 8,
		backgroundColor: "#D6DEE8",
	},
});
