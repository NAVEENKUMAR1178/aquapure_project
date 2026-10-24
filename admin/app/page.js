'use client';
import { useEffect, useState } from 'react';
import { signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { collection, doc, getDoc, onSnapshot, updateDoc, setDoc, writeBatch, orderBy, query } from 'firebase/firestore';
import { auth, db } from './firebase';

const ORDER_STATUSES = ['Placed', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'];
const SERVICE_STATUSES = ['Open', 'Scheduled', 'In Progress', 'Resolved'];
const card = { background: '#fff', padding: 14, borderRadius: 10, marginBottom: 10, boxShadow: '0 1px 3px #0002' };
const btn = { padding: '6px 12px', marginRight: 6, border: 0, borderRadius: 6, background: '#1e88e5', color: '#fff', cursor: 'pointer' };

function useCol(name, ready, order) {
  const [rows, setRows] = useState([]);
  useEffect(() => {
    if (!ready) return;
    const q = order ? query(collection(db, name), orderBy(order, 'desc')) : collection(db, name);
    return onSnapshot(q, (s) => setRows(s.docs.map((d) => ({ id: d.id, ...d.data() }))));
  }, [ready]);
  return rows;
}

export default function Admin() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [checking, setChecking] = useState(true);
  const [tab, setTab] = useState('orders');
  const [email, setEmail] = useState('');
  const [pass, setPass] = useState('');
  const [msg, setMsg] = useState('');

  useEffect(() => onAuthStateChanged(auth, async (u) => {
    setUser(u);
    if (u) { const d = await getDoc(doc(db, 'users', u.uid)); setIsAdmin(d.data()?.role === 'Admin'); }
    setChecking(false);
  }), []);

  const orders = useCol('orders', isAdmin, 'createdAt');
  const services = useCol('services', isAdmin, 'createdAt');
  const users = useCol('users', isAdmin);
  const products = useCol('products', isAdmin);
  const dealers = users.filter((u) => u.role === 'Dealer');

  async function notify(uid, title, body) {
    try {
      const token = await auth.currentUser.getIdToken();
      await fetch('/api/notify', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + token }, body: JSON.stringify({ uid, title, body }) });
    } catch {}
  }
  const setOrder = async (o, status) => { await updateDoc(doc(db, 'orders', o.id), { status }); notify(o.uid, 'Order update', `Your order is now ${status}`); };
  const setService = async (s, status) => { await updateDoc(doc(db, 'services', s.id), { status }); notify(s.uid, 'Service update', `Your ${s.type} request is ${status}`); };
  const setDealer = async (d, approved) => { await updateDoc(doc(db, 'users', d.id), { approved }); notify(d.id, 'Dealer account', approved ? 'Approved! You can start ordering.' : 'Application rejected.'); };

  async function seed() {
    const list = await (await fetch('/products.json')).json();
    const b = writeBatch(db);
    list.forEach((p) => { const { id, ...rest } = p; b.set(doc(db, 'products', id), { ...rest, image: location.origin + p.image }); });
    await b.commit();
    setMsg(`Seeded ${list.length} products`);
  }

  if (checking) return <p style={{ padding: 20 }}>Loading…</p>;
  if (!user || !isAdmin)
    return (
      <div style={{ maxWidth: 340, margin: '80px auto', ...card }}>
        <h2>AquaPure Admin</h2>
        {user && !isAdmin && <p style={{ color: 'red' }}>This account is not an Admin.</p>}
        <input placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} style={{ width: '100%', marginBottom: 8, padding: 8 }} />
        <input placeholder="Password" type="password" value={pass} onChange={(e) => setPass(e.target.value)} style={{ width: '100%', marginBottom: 8, padding: 8 }} />
        <button style={btn} onClick={() => signInWithEmailAndPassword(auth, email, pass).catch((e) => setMsg(e.message))}>Login</button>
        {user && <button style={btn} onClick={() => signOut(auth)}>Logout</button>}
        <p style={{ color: 'red', fontSize: 12 }}>{msg}</p>
      </div>
    );

  return (
    <div style={{ maxWidth: 1000, margin: '0 auto', padding: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2>💧 AquaPure Admin</h2>
        <button style={btn} onClick={() => signOut(auth)}>Logout</button>
      </div>
      <div style={{ marginBottom: 12 }}>
        {['orders', 'dealers', 'service', 'products'].map((t) => (
          <button key={t} onClick={() => setTab(t)} style={{ ...btn, background: tab === t ? '#0d47a1' : '#90a4ae' }}>
            {t[0].toUpperCase() + t.slice(1)}
          </button>
        ))}
      </div>
      {msg && <p>{msg}</p>}

      {tab === 'orders' && orders.map((o) => (
        <div key={o.id} style={card}>
          <b>#{o.id.slice(0, 6)}</b> · {o.userName} ({o.role}) · <b>₹{o.total}</b>
          <div style={{ fontSize: 13, color: '#555' }}>{o.address} · Payment: {o.paymentId}</div>
          <ul style={{ margin: '6px 0' }}>{o.items?.map((i, k) => <li key={k}>{i.name} × {i.qty} @ ₹{i.price}</li>)}</ul>
          <select value={o.status} onChange={(e) => setOrder(o, e.target.value)}>
            {ORDER_STATUSES.map((s) => <option key={s}>{s}</option>)}
          </select>
        </div>
      ))}

      {tab === 'dealers' && (dealers.length === 0 ? <p>No dealer sign-ups yet.</p> : dealers.map((d) => (
        <div key={d.id} style={card}>
          <b>{d.name}</b> · {d.email} · {d.phone} · {d.approved ? '✅ Approved' : '⏳ Pending'}
          <div style={{ marginTop: 8 }}>
            <button style={btn} onClick={() => setDealer(d, true)}>Approve</button>
            <button style={{ ...btn, background: '#e53935' }} onClick={() => setDealer(d, false)}>Reject</button>
          </div>
        </div>
      )))}

      {tab === 'service' && services.map((s) => (
        <div key={s.id} style={card}>
          <b>{s.type}</b> · {s.userName} · {s.date?.toDate?.().toDateString()}
          <div style={{ fontSize: 13 }}>{s.description} — {s.address}</div>
          <select value={s.status} onChange={(e) => setService(s, e.target.value)}>
            {SERVICE_STATUSES.map((x) => <option key={x}>{x}</option>)}
          </select>
        </div>
      ))}

      {tab === 'products' && (
        <>
          <button style={btn} onClick={seed}>Seed / reset 52 sample products</button>
          <p>{products.length} products in Firestore.</p>
          {products.map((p) => (
            <div key={p.id} style={{ ...card, display: 'flex', gap: 10, alignItems: 'center' }}>
              <img src={p.image} width={50} height={50} alt="" />
              <span style={{ flex: 1 }}>{p.name} <small>({p.category})</small></span>
              <span>₹<input type="number" defaultValue={p.price} style={{ width: 70 }} onBlur={(e) => updateDoc(doc(db, 'products', p.id), { price: +e.target.value })} /></span>
              <span>W ₹<input type="number" defaultValue={p.wholesalePrice} style={{ width: 70 }} onBlur={(e) => updateDoc(doc(db, 'products', p.id), { wholesalePrice: +e.target.value })} /></span>
            </div>
          ))}
        </>
      )}
    </div>
  );
}
