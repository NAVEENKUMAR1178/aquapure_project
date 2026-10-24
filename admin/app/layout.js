export const metadata = { title: 'AquaPure Admin' };
export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, sans-serif', margin: 0, background: '#f3f6fa' }}>
        {children}
      </body>
    </html>
  );
}
