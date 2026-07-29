import { auth, currentUser } from "@clerk/nextjs/server";
import { db } from "./prisma";
import { cache } from "react";

export const getAuthenticatedUser = cache(async () => {
  const { userId } = await auth();
  if (!userId) return null;

  return await db.user.findUnique({
    where: {
      clerkUserId: userId,
    },
  });
});

export const checkUser = async () => {
  const loggedInUser = await getAuthenticatedUser();
  if (loggedInUser) {
    return loggedInUser;
  }

  const { userId } = await auth();
  if (!userId) return null;

  try {
    const user = await currentUser();
    if (!user) return null;

    const name = `${user.firstName || ""} ${user.lastName || ""}`.trim();

    const newUser = await db.user.create({
      data: {
        clerkUserId: user.id,
        name,
        imageUrl: user.imageUrl,
        email: user.emailAddresses[0]?.emailAddress,
      },
    });

    return newUser;
  } catch (error) {
    console.log(error.message);
  }
};
