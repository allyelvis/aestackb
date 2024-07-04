#!/bin/bash

# Define project name and directory
PROJECT_NAME="aenzbi-inventory-invoicing"
PROJECT_DIR="$HOME/$PROJECT_NAME"

# Create project directory
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Initialize a new Node.js project
npm init -y

# Install necessary dependencies
npm install express axios body-parser nodemon

# Create basic project structure
mkdir -p src/routes src/controllers src/models src/utils

# Create server.js
cat <<EOL > server.js
const express = require('express');
const bodyParser = require('body-parser');
const invoiceRoutes = require('./src/routes/invoiceRoutes');
const inventoryRoutes = require('./src/routes/inventoryRoutes');

const app = express();
app.use(bodyParser.json());

app.use('/api/invoices', invoiceRoutes);
app.use('/api/inventory', inventoryRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(\`Server is running on port \${PORT}\`);
});
EOL

# Create invoiceRoutes.js
cat <<EOL > src/routes/invoiceRoutes.js
const express = require('express');
const { postInvoice } = require('../controllers/invoiceController');

const router = express.Router();

router.post('/', postInvoice);

module.exports = router;
EOL

# Create inventoryRoutes.js
cat <<EOL > src/routes/inventoryRoutes.js
const express = require('express');
const { postInventory } = require('../controllers/inventoryController');

const router = express.Router();

router.post('/', postInventory);

module.exports = router;
EOL

# Create invoiceController.js
cat <<EOL > src/controllers/invoiceController.js
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const EBMS_URL = 'https://ebms.obr.gov.bi:9443/ebms_api/getInvoice';
const BEARER_TOKEN = 'YOUR_EBMS_BEARER_TOKEN';

const postInvoice = async (req, res) => {
    try {
        const response = await axios.post(EBMS_URL, req.body, {
            headers: {
                'Authorization': \`Bearer \${BEARER_TOKEN}\`,
                'Content-Type': 'application/json'
            }
        });
        const invoiceFilePath = path.join(__dirname, '../../invoice_bill.txt');
        const footerSignature = \`Response: \${JSON.stringify(response.data)}\`;
        fs.appendFileSync(invoiceFilePath, \`\\n\\n\${footerSignature}\`);
        res.status(200).send(response.data);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

module.exports = { postInvoice };
EOL

# Create inventoryController.js
cat <<EOL > src/controllers/inventoryController.js
const axios = require('axios');

const EBMS_URL = 'https://ebms.obr.gov.bi:9443/ebms_api/postInventory';
const BEARER_TOKEN = 'YOUR_EBMS_BEARER_TOKEN';

const postInventory = async (req, res) => {
    try {
        const response = await axios.post(EBMS_URL, req.body, {
            headers: {
                'Authorization': \`Bearer \${BEARER_TOKEN}\`,
                'Content-Type': 'application/json'
            }
        });
        res.status(200).send(response.data);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

module.exports = { postInventory };
EOL

# Create utils directory for any utility functions if needed
touch src/utils/utils.js

# Create empty models if needed
touch src/models/invoiceModel.js
touch src/models/inventoryModel.js

# Add a start script to package.json
sed -i '/"scripts": {/a \ \ \ \ "start": "nodemon server.js",' package.json

# Print success message
echo "Node.js backend project for invoicing and inventory management has been set up successfully!"

# Note: Replace 'YOUR_EBMS_BEARER_TOKEN' with your actual EBMS bearer token
