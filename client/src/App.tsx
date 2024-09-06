import { ConnectButton } from "thirdweb/react";
import thirdwebIcon from "./thirdweb.svg";
import { client } from "./client";
import Login from "./pages/Login";
import Chat from "./components/Chat";
import ChatPage from "./pages/ChatPage";
import MyChats from "./components/MyChats";

export function App() {
  return (
    <div className="flex flex-col space-y-2">
      <ChatPage />
    </div>
  );
}
