import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// Almacenamiento temporal de códigos de recuperación
const recoveryCodes = {};

// Generar código aleatorio de 6 dígitos
function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Endpoint para enviar código de recuperación
app.post('/auth/recovery-code', (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ message: 'Email requerido' });
  }
  const code = generateCode();
  recoveryCodes[email] = code;
  // Simular envío de email (imprimir en consola)
  console.log(`Código de recuperación para ${email}: ${code}`);
  res.json({ message: 'Código de recuperación enviado (simulado)' });
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

app.listen(PORT, () => {
  console.log(`Servidor backend escuchando en http://localhost:${PORT}`);
}); 