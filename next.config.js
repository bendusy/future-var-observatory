/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',  // 改为静态导出
  images: {
    unoptimized: true
  },
  typescript: {
    ignoreBuildErrors: true
  },
  eslint: {
    ignoreDuringBuilds: true
  },
  webpack: (config, { isServer }) => {
    // 优化构建大小
    config.optimization = {
      ...config.optimization,
      minimize: true,
      splitChunks: {
        chunks: 'all',
        minSize: 20000,
        maxSize: 24000000, // 24MB
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name(module) {
              const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1];
              return `vendor.${packageName.replace('@', '')}`;
            },
          },
        },
      },
    }

    // Windows 特定配置
    if (process.platform === 'win32') {
      config.watchOptions = {
        poll: false,
        aggregateTimeout: 300,
        ignored: ['**/.git/**', '**/node_modules/**', '**/.next/**']
      }
    }

    return config
  },
  // 禁用快速刷新（热更新）
  devIndicators: {
    buildActivity: false
  },
  reactStrictMode: false
}

module.exports = nextConfig
