import React from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  useLocation,
} from "react-router-dom";
import Home from "./pages/Home";
import SideBar from "./components/SideBar";
import Header from "./components/Header";
import Login from "./pages/Login";
import ChatPage from "./pages/ChatPage";
import ViewProfile from "./pages/Profile";

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const location = useLocation();
  const isLoginPage = location.pathname === "/login";

  return (
    <div>
      {!isLoginPage && <SideBar />}
      {!isLoginPage && <Header />}
      <div className="flex-grow">{children}</div>
    </div>
  );
};

const App: React.FC = () => {
  //const { SocialContract } = useSocialTokenContext(); // Assuming you have a context hook for SocialContract

  return (
    <Router>
      {/* // <DndProvider backend={HTML5Backend}> */}
      <Routes>
        <Route
          path="/"
          element={
            <Layout>
              <Home />
            </Layout>
          }
        />
        <Route
          path="/chat"
          element={
            <Layout>
              <ChatPage />
            </Layout>
          }
        />
        <Route
          path="/profile"
          element={
            <Layout>
              <ViewProfile />
            </Layout>
          }
        />
        <Route path="/login" element={<Login />} />
      </Routes>
      {/* </DndProvider> */}
    </Router>
  );
};

export default App;
