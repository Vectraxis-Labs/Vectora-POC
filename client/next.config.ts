import type { NextConfig } from "next";

const nextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "http://backend:8000/:path*",
      },
    ];
  },
};

module.exports = nextConfig;
