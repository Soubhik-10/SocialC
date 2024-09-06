import React, { useState, useEffect, useRef } from "react";
import { FaCheckCircle } from "react-icons/fa";
import { useParams } from "react-router-dom";
import { useActiveAccount } from "thirdweb/react";
import Rings from "../components/Rings";

const ViewProfile: React.FC = () => {
  const { userId } = useParams();
  const acc = useActiveAccount()?.address;
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [user, setUser] = useState<any>({
    name: "John Doe",
    userid: "0x1234567890abcdef1234567890abcdef12345678",
    bio: "A passionate blockchain developer.",
    imageHash: "path_to_dummy_image.jpg",
    contactDetails: "john.doe@example.com",
    premiumUser: true,
  });

  const [imageUrl, setImageUrl] = useState<string>("");
  const [newImage, setNewImage] = useState<File | null>(null);

  useEffect(() => {
    const fetchUserImage = async () => {
      try {
        setImageUrl(user.imageHash);
      } catch (error) {
        console.error("Failed to fetch user image", error);
        setImageUrl("path_to_dummy_image.jpg");
      }
    };
    fetchUserImage();
  }, [user]);

  const handleProfilePicChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files[0]) {
      setNewImage(event.target.files[0]);
      const fileUrl = URL.createObjectURL(event.target.files[0]);
      setImageUrl(fileUrl);
    }
  };

  const handleUpload = async () => {
    if (newImage) {
      // Implement the upload logic here
      console.log("Uploading new image:", newImage);
    }
  };

  const handleChangeProfilePictureClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click(); // Trigger the hidden file input
    }
  };

  return (
    <div className="relative w-full h-screen overflow-hidden">
      {/* Vanta Background */}
      <Rings />

      {/* Fullscreen Transparent Content Container */}
      <div className="absolute top-0 left-0 w-full h-full flex items-center justify-center">
        <div className="bg-gray-800 bg-opacity-70 p-12 w-full max-w-screen h-full max-h-screen rounded-lg shadow-lg text-center overflow-auto">
          {user && (
            <div className="flex flex-col items-center justify-center w-full h-full">
              <img
                src={imageUrl}
                alt="Profile"
                className="h-32 w-32 sm:h-40 sm:w-40 rounded-full border-4 border-white"
              />
              <h1 className="text-4xl sm:text-5xl font-bold text-white mt-6 flex items-center">
                {user.name}
                {user.premiumUser && <FaCheckCircle className="text-green-500 ml-2 text-2xl" />}
              </h1>
              <p className="text-gray-400 text-xl hidden lg:block">@{user.userid}</p>
              <p className="text-gray-400 text-xl block lg:hidden">
                @{user.userid.slice(0, 4) + "..." + user.userid.slice(36, 40)}
              </p>
              <p className="text-gray-300 mt-4 text-xl">{user.bio}</p>

              <div className="mt-8">
                <h2 className="text-2xl font-semibold text-white">Contact Details:</h2>
                <p className="text-gray-400 text-xl">{user.contactDetails}</p>
              </div>

              <div className="mt-8">
                {acc === userId ? (
                  <div className="flex flex-col items-center space-y-4">
                    <button
                      className="px-6 py-3 bg-green-500 text-white rounded-lg text-lg"
                      onClick={handleChangeProfilePictureClick}
                    >
                      Change Profile Picture
                    </button>

                    <input
                      type="file"
                      accept="image/*"
                      ref={fileInputRef}
                      style={{ display: "none" }}
                      onChange={handleProfilePicChange}
                    />

                    {newImage && (
                      <button
                        className="px-6 py-3 bg-blue-500 text-white rounded-lg text-lg"
                        onClick={handleUpload}
                      >
                        Upload New Picture
                      </button>
                    )}
                  </div>
                ) : (
                  <button className="px-6 py-3 bg-blue-500 text-white rounded-lg text-lg">
                    Chat with {user.name}
                  </button>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ViewProfile;
