"use client";

import React, { useEffect, useState } from "react";
import { v4 as uuidv4 } from "uuid";

import { invoke, query } from "../../config/api";
import { wait } from "../../utils/promise";

const App = () => {
	const [data, setData] = useState<any>(null);

	useEffect(() => {
		const runAssetFlow = async () => {
			const uniqueId = String(uuidv4());

			try {
				const postData = await invoke({
					channelid: "mychannel",
					chaincodeid: "basic",
					function: "CreateAsset",
					args: [uniqueId, "red", "54", "Tom", "13005"],
				});

				await wait(1000);

				await invoke({
					channelid: "mychannel",
					chaincodeid: "basic",
					function: "UpdateAsset",
					args: [uniqueId, "red", "54", "X", "13005"],
				});

				await wait(1000);

				await invoke({
					channelid: "mychannel",
					chaincodeid: "basic",
					function: "UpdateAsset",
					args: [uniqueId, "red", "54", "Y", "13005"],
				});

				await wait(1000);

				await invoke({
					channelid: "mychannel",
					chaincodeid: "basic",
					function: "UpdateAsset",
					args: [uniqueId, "red", "54", "Z", "13005"],
				});

				await wait(1000);

				await invoke({
					channelid: "mychannel",
					chaincodeid: "basic",
					function: "DeleteAsset",
					args: [uniqueId],
				});

				await wait(1000);

				const responseData = await query({
					channelid: "mychannel",
					chaincodeid: "basic",
					function: "GetAssetRecords",
					args: [uniqueId],
				});
				setData(responseData);
				console.log("POST request successful:", postData);
			} catch (error) {
				console.error("Error fetching data:", error);
			}
		};

		const timeout = setTimeout(runAssetFlow, 500);

		return () => clearTimeout(timeout);

		// INFO: we can have more than one transaction per block
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
		// runAssetFlow();
	}, []);

	return (
		<div className="min-h-screen flex flex-col items-center justify-center space-y-8 p-4">
			<h1 className="text-4xl font-bold text-center">Asset Records</h1>
			<div className="flex items-center justify-center space-x-8">
				{data && (
					<pre className="whitespace-pre-wrap overflow-auto p-2 border border-gray-300 rounded-md bg-gray-100">
						{JSON.stringify(data, null, 2)}
					</pre>
				)}
			</div>
		</div>
	);
};

export default App;
