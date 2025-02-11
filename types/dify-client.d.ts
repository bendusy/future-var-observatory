declare module 'dify-client' {
    export interface DifyConfig {
        apiKey: string;
        baseUrl?: string;
    }

    export class DifyClient {
        constructor(config: DifyConfig);
        // 添加其他需要的方法声明
    }

    export default DifyClient;
} 