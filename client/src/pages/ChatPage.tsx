import React from "react";
import Chat from "../components/Chat";
import User from "../components/User";
import MyChats from "../components/MyChats"; // Import MyChats component

const ChatPage = () => {
  return (
    <div className="w-screen h-screen flex">
      {/* Left Side - MyChats */}
      <div className="w-2/5 bg-zinc-950 border-r-2 border-white mt-16">
        <MyChats />
      </div>

      {/* Right Side - Chat Section */}
      <div className="w-3/5 flex flex-col  mt-16">
        {/* Sticky User Component */}
        <div className="sticky top-0 z-10 bg-black border-b-2 border-white">
          <User name="Soubhik Singha Mahapatra" userId="soubhik_smp" />
        </div>

        {/* Scrollable Chat Messages */}
        <div className="flex flex-col overflow-y-scroll p-4 md:p-5 no-scrollbar">
          <Chat message="Hello, how are you?" time="10:45 AM" isUser={false} />
          <Chat message="I'm good, thanks!" time="10:46 AM" isUser={true} />
          <Chat message="What about you?" time="10:47 AM" isUser={true} />
          <Chat message="Doing great!" time="10:48 AM" isUser={false} />
          <Chat message="I'm good, thanks!" time="10:46 AM" isUser={true} />
          <Chat message="What about you?" time="10:47 AM" isUser={true} />
          <Chat message="Doing great!" time="10:48 AM" isUser={false} />
          <Chat message="I'm good, thanks!" time="10:46 AM" isUser={true} />
          <Chat message="What about you?" time="10:47 AM" isUser={true} />
          <Chat message="Doing great!" time="10:48 AM" isUser={false} />
          <Chat message="I'm good, thanks!" time="10:46 AM" isUser={true} />
          <Chat message="What about you?" time="10:47 AM" isUser={true} />
          <Chat message="Doing great!" time="10:48 AM" isUser={false} />
          {/* Add more Chat components as needed */}
        </div>
      </div>
    </div>
  );
};

export default ChatPage;
