import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import nodemailer from 'nodemailer';
import dotenv from 'dotenv';
import { MongoClient } from 'mongodb';
import CryptoJS from 'crypto-js';

dotenv.config();

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// Almacenamiento temporal de códigos de recuperación
const recoveryCodes = {};

// Configuración de nodemailer
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT),
  secure: true, // true para 465, false para otros puertos
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// Conexión a MongoDB
const mongoUri = process.env.MONGO_URI || 'mongodb+srv://rogerjove2005:rogjov01@cluster0.rxxyf.mongodb.net/Projecte2025Chats';
const client = new MongoClient(mongoUri);
let usersCollection;

async function connectMongo() {
  if (!usersCollection) {
    await client.connect();
    const db = client.db('Projecte2025Chats');
    usersCollection = db.collection('users');
    console.log('Conectado a MongoDB desde backend');
  }
}

// Generar código aleatorio de 6 dígitos
function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Endpoint para enviar código de recuperación
app.post('/auth/recovery-code', async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ message: 'Email requerido' });
  }
  const code = generateCode();
  recoveryCodes[email] = code;
  try {
    await transporter.sendMail({
      from: process.env.SMTP_USER,
      to: email,
      subject: 'Código de recuperación',
      text: `Tu código de recuperación es: ${code}`,
      html: `<p>Tu código de recuperación es: <b>${code}</b></p>`
    });
    res.json({ message: 'Código de recuperación enviado al email' });
  } catch (error) {
    console.error('Error enviando email:', error);
    res.status(500).json({ message: 'Error enviando email de recuperación' });
  }
});

// Endpoint para verificar el código
app.post('/auth/verify-code', (req, res) => {
  const { email, code } = req.body;
  if (!email || !code) {
    return res.status(400).json({ message: 'Email y código requeridos' });
  }
  if (recoveryCodes[email] === code) {
    delete recoveryCodes[email];
    return res.json({ message: 'Código verificado correctamente' });
  } else {
    return res.status(400).json({ message: 'Código incorrecto' });
  }
});

// Endpoint para restablecer la contraseña
app.post('/auth/reset-password', async (req, res) => {
  const { email, code, newPassword } = req.body;
  if (!email || !code || !newPassword) {
    return res.status(400).json({ message: 'Faltan datos' });
  }
  // Verifica el código
  if (recoveryCodes[email] !== code) {
    return res.status(400).json({ message: 'Código de recuperación inválido' });
  }
  try {
    await connectMongo();
    // Hash de la nueva contraseña (igual que en Flutter)
    const hashedPassword = CryptoJS.SHA256(newPassword).toString();
    const result = await usersCollection.updateOne(
      { email },
      { $set: { password: hashedPassword, updatedAt: new Date().toISOString() } }
    );
    delete recoveryCodes[email];
    if (result.modifiedCount === 1) {
      return res.json({ message: 'Contraseña restablecida correctamente' });
    } else {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error('Error actualizando contraseña:', error);
    return res.status(500).json({ message: 'Error actualizando contraseña' });
  }
});

// Endpoint para eliminar cuenta
app.post('/auth/delete-account', async (req, res) => {
  const { email } = req.body;
  console.log('Delete account request for:', email);
  if (!email) {
    return res.status(400).json({ message: 'Email requerido' });
  }
  try {
    await connectMongo();
    const user = await usersCollection.findOne({ email });
    if (!user) {
      console.log('User not found:', email);
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    const result = await usersCollection.deleteOne({ email });
    if (result.deletedCount === 1) {
      console.log('User deleted:', email);
      return res.json({ message: 'Cuenta eliminada correctamente' });
    } else {
      console.log('Delete failed for:', email);
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error('Error eliminando cuenta:', error);
    return res.status(500).json({ message: 'Error eliminando cuenta' });
  }
});

// Endpoint para obtener todos los usuarios
app.get('/auth/all-users', async (req, res) => {
  try {
    await connectMongo();
    const users = await usersCollection.find({}, { projection: { password: 0 } }).toArray();
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Error fetching users' });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor backend escuchando en http://localhost:${PORT}`);
}); 