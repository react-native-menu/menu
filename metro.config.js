const path = require("node:path");

const { makeMetroConfig } = require("@rnx-kit/metro-config");
module.exports = makeMetroConfig({
	projectRoot: path.join(__dirname, "example"),
	watchFolders: [__dirname],
	resolver: {
		extraNodeModules: {
			"@react-native-menu/menu": __dirname,
		},
	},
	transformer: {
		getTransformOptions: async () => ({
			transform: {
				experimentalImportSupport: false,
				inlineRequires: false,
			},
		}),
	},
});
