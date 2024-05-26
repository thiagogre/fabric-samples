"use client";

import React, { useEffect, useState } from "react";
import { v4 as uuidv4 } from "uuid";

import { invoke, query } from "../config/api";
import { wait } from "../utils/promise";

import Carousel from "../components/carousel/Carousel";
import Button from "../components/button/Button";
import ImageTable from "../components/imageTable/ImageTable";
import Event from "../components/event/Event";
import { Event as EventType } from "@/components/event/types";

const App: React.FC = () => {
	const [data, setData] = useState<any>(null);
	const [events, setEvents] = useState<EventType[] | []>([]);

	const images = [
		"https://via.placeholder.com/600x400",
		"https://via.placeholder.com/600x400/ff7f7f",
		"https://via.placeholder.com/600x400/7f7fff",
	];

	const imageData = [
		{
			name: "Image 1",
			size: "200 KB",
			pixels: "600x400",
			dimensions: "600x400",
		},
		{
			name: "Image 2",
			size: "210 KB",
			pixels: "600x400",
			dimensions: "600x400",
		},
		{
			name: "Image 3",
			size: "220 KB",
			pixels: "600x400",
			dimensions: "600x400",
		},
	];

	const handleClick = async () => {
		const uniqueId = String(uuidv4());

		try {
			const postData = await invoke({
				channelid: "mychannel",
				chaincodeid: "basic",
				function: "CreateAsset",
				args: [uniqueId, "red", "54", "Tom", "13005"],
			});

			await wait(5000);

			await invoke({
				channelid: "mychannel",
				chaincodeid: "basic",
				function: "UpdateAsset",
				args: [uniqueId, "red", "54", "X", "13005"],
			});

			await wait(5000);

			await invoke({
				channelid: "mychannel",
				chaincodeid: "basic",
				function: "UpdateAsset",
				args: [uniqueId, "red", "54", "Y", "13005"],
			});

			await wait(5000);

			await invoke({
				channelid: "mychannel",
				chaincodeid: "basic",
				function: "UpdateAsset",
				args: [uniqueId, "red", "54", "Z", "13005"],
			});

			await wait(5000);

			// await invoke({
			// 	channelid: "mychannel",
			// 	chaincodeid: "basic",
			// 	function: "DeleteAsset",
			// 	args: [uniqueId],
			// });

			// await wait(5000);

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

	const getEvents = async () => {
		try {
			const req = await fetch("http://localhost:3001/events");
			setEvents((await req.json())?.docs ?? []);
		} catch (error) {
			console.error("Error fetching events: ", error);
		}
	};

	return (
		<div className="min-h-screen flex flex-col items-center justify-center space-y-8 p-4">
			<h1 className="text-4xl font-bold text-center">Celulares</h1>
			{JSON.stringify(data)}
			<div className="flex items-center justify-center space-x-8">
				<Carousel images={images} />
				<ImageTable data={imageData} />
			</div>
			<div className="mt-8">
				<Button onClick={handleClick}>Primary Button</Button>
			</div>
			<div className="mt-8">
				<Button onClick={getEvents}>Events</Button>
			</div>
			<div>
				{events.toReversed().map((event, index) => (
					<Event key={index} {...event} />
				))}
			</div>
		</div>
	);
};

export default App;
