import React from "react";
import User from "./User";

const MyChats = () => {
  return (
    <div className="h-full">
      {" "}
      {/* Ensure the parent container has full height */}
      <div className="p-4 flex flex-col space-y-2 overflow-y-scroll h-full no-scrollbar">
        {[...Array(7)].map((_, index) => (
          <div key={index} className="hover:bg-zinc-400">
            <User />
          </div>
        ))}
      </div>
    </div>
  );
};

export default MyChats;
