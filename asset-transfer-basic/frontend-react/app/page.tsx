"use client";

import React from "react";
import { useRouter } from "next/navigation";

import Button from "../components/button/Button";

const App = () => {
	const router = useRouter();

	return (
		<div className="min-h-screen flex flex-col items-center justify-center space-y-8 p-4">
			<h1 className="text-4xl font-bold text-center">Home</h1>
			<div className="flex flex-col md:flex-row items-start justify-center space-y-8 space-x-8 mt-8 w-full">
				<div className="mt-8 flex flex-col items-center space-y-4">
					<Button onClick={() => router.push("/asset-records")}>
						Asset Records
					</Button>
				</div>
				<div className="mt-8 flex flex-col items-center space-y-4">
					<Button onClick={() => router.push("/events")}>
						Events
					</Button>
				</div>
			</div>
		</div>
	);
};

export default App;
