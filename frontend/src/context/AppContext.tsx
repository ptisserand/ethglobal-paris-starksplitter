import React, { useCallback, useRef, useState } from "react";

type AppContextType = {
    splitterContract: string;
    setSplitterContract: React.Dispatch<React.SetStateAction<string>>;
}

const AppContext = React.createContext<null | AppContextType>(null);

type Props = {
    children: React.ReactNode;
}

export const AppContextProvider = ({ children }: Props) => {
    const [splitterContract, setSplitterContract] = useState("");

    return (
        <AppContext.Provider value={{
            splitterContract,
            setSplitterContract,
        }}>
            {children}
        </AppContext.Provider>
    )
}

export const useAppContext = () => {
    const appContext = React.useContext(AppContext);

    if (!appContext) throw new Error("You need to use this context inside a provider");

    return appContext;
}