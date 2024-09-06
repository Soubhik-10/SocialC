// Chat.tsx
import React from "react";

interface ChatProps {
  message: string;
  time: string;
  isUser: boolean;
}

const Chat: React.FC<ChatProps> = ({ message, time, isUser }) => {
  return (
    <div
      className={`max-w-xs text-xs md:text-sm md:max-w-md lg:max-w-lg xl:max-w-xl p-3 my-2 rounded-3xl shadow-lg ${
        isUser
          ? "bg-blue-500 text-white self-end"
          : "bg-gray-300 text-black self-start"
      }`}
      style={{ alignSelf: isUser ? "flex-end" : "flex-start" }} // Ensure proper alignment
    >
      <p className="break-words text-sm md:text-lg">{message}</p>
      <p className="text-xs mt-1 text-right ">{time}</p>
    </div>
  );
};

export default Chat;
