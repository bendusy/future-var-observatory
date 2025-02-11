declare module '@dify/client' {
    interface DifyConfig {
        apiKey: string;
        baseUrl?: string;
        userId?: string;
    }

    interface MessageResponse {
        id: string;
        content: any;
    }

    class DifyClient {
        constructor(config: DifyConfig);
        createConversation(): Promise<any>;
        sendMessage(message: string, options?: any): Promise<MessageResponse>;
    }

    export default DifyClient;
} 