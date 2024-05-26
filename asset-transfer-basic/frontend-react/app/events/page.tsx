"use client";

import { useEffect, useState } from "react";

import Event from "../../components/event/Event";
import { Event as EventType } from "../../components/event/types";

const Events = () => {
	const [events, setEvents] = useState<Record<number, EventType[]>>({});

	useEffect(() => {
		// Group events by block number
		const groupedEvents = (docs: EventType[] | []) =>
			docs.reduce((acc, event) => {
				if (!acc[event.BlockNumber]) {
					acc[event.BlockNumber] = [];
				}
				acc[event.BlockNumber].push(event);
				return acc;
			}, {} as Record<number, EventType[]>);

		const getEvents = async () => {
			try {
				const res = await fetch("http://localhost:3001/events");
				const docs: EventType[] | [] = (await res.json())?.docs ?? [];
				setEvents(groupedEvents(docs));
			} catch (error) {
				console.error("Error fetching events: ", error);
			}
		};

		getEvents();
		const interval = setInterval(getEvents, 5000);

		return () => clearInterval(interval);
	}, []);

	return (
		<div className="min-h-screen flex flex-col items-center justify-center p-4 bg-gray-50">
			<h1 className="text-3xl font-bold mb-8">Events</h1>
			<div className="w-full max-w-6xl flex flex-col justify-center gap-4">
				{Object.entries(events)
					.toReversed()
					.map(([blockNumber, events]) => (
						<div
							key={blockNumber}
							className="w-full border border-gray-300 bg-gray-200 shadow-lg rounded-lg p-6 mb-8"
						>
							<h2 className="text-2xl font-semibold mb-4">
								Block #{blockNumber}
							</h2>
							<div className="w-full flex flex-wrap justify-center gap-4">
								{events.map((event, index) => (
									<Event
										key={index}
										{...event}
										isBlockHidden
									/>
								))}
							</div>
						</div>
					))}
			</div>
		</div>
	);
};

export default Events;
