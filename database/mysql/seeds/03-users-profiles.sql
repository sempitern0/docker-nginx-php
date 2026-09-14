-- Demo profiles. All addresses are synthetic/fictitious data.
-- MariaDB syntax only.

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Admin', 'Demo', NULL, NULL, NULL, NULL, 'ES'
FROM users
WHERE username = 'admin';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Normal', 'Demo', NULL, NULL, NULL, NULL, 'ES'
FROM users
WHERE username = 'user';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Guest', 'Demo', NULL, NULL, NULL, NULL, 'ES'
FROM users
WHERE username = 'guest';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Adrián', 'Alonso Díaz', NULL, 'Calle del Prado Nuevo 10', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'user001';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alba', 'Blanco Gallardo', NULL, 'Avenida de la Dehesa Alta 11', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'user002';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alejandro', 'Campos Hernández', NULL, 'Carrer de la Marina Nova 12', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'user003';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alicia', 'Crespo Marín', NULL, 'Carrer del Montseny Blau 13', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'user004';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Álvaro', 'Domínguez Montes', NULL, 'Carrer de l’Albufera Nova 14', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'user005';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Ana', 'Fernández Ortega', NULL, 'Carrer del Túria Vell 15', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'user006';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Andrés', 'Gallardo Ramírez', NULL, 'Calle del Guadalquivir Alto 16', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'user007';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Beatriz', 'Gómez Sáez', NULL, 'Calle de la Giralda Clara 17', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'user008';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Bruno', 'Gutiérrez Vargas', NULL, 'Calle del Ebro Interior 18', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'user009';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carla', 'Jiménez Cabrera', NULL, 'Calle del Mediterráneo Sur 19', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'user010';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carlos', 'Lorenzo Díaz', NULL, 'Avenida de la Huerta Nueva 20', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'user011';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Clara', 'Márquez Gallardo', NULL, 'Carrer de la Serra Blanca 21', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'user012';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniel', 'Medina Hernández', NULL, 'Calle del Atlántico Claro 22', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'user013';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniela', 'Montes Marín', NULL, 'Calle de la Costa Serena 23', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'user014';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'David', 'Moya Montes', NULL, 'Calle del Nervión Verde 24', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'user015';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Diego', 'Núñez Ortega', NULL, 'Rúa do Atlántico Norte 25', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'user016';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elena', 'Pascual Ramírez', NULL, 'Calle del Pisuerga Nuevo 26', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'user017';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elías', 'Pérez Sáez', NULL, 'Rúa das Illas Atlánticas 27', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'user018';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Eva', 'Ramos Vargas', NULL, 'Calle del Cantábrico Norte 28', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'user019';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Fernando', 'Romero Cabrera', NULL, 'Calle de Sierra Clara 29', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'user020';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gabriel', 'Sáez Díaz', NULL, 'Avenida del Teide Alto 30', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'user021';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gema', 'Sanz Gallardo', NULL, 'Calle de la Sierra Morena 31', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'user022';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Guillermo', 'Torres Hernández', NULL, 'Calle de Navarra Central 32', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'user023';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Héctor', 'Vega Marín', NULL, 'Calle de la Bahía Alta 33', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'user024';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Irene', 'Benítez Montes', NULL, 'Calle del Tormes Claro 34', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'user025';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Iván', 'Calvo Ortega', NULL, 'Calle de los Cigarrales Nuevos 35', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'user026';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Javier', 'Cortés Ramírez', NULL, 'Calle del Arlanzón Norte 36', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'user027';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jimena', 'Díaz Sáez', NULL, 'Calle del Ebro Riojano 37', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'user028';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jorge', 'Esteban Vargas', NULL, 'Calle del Naranco Nuevo 38', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'user029';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Julia', 'Fuentes Cabrera', NULL, 'Avenida de la Bahía Serena 39', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'user030';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Laura', 'Giménez Díaz', NULL, 'Calle del Prado Nuevo 40', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'user031';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leire', 'Guerrero Gallardo', NULL, 'Avenida de la Dehesa Alta 41', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'user032';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leo', 'Iglesias Hernández', NULL, 'Carrer de la Marina Nova 42', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'user033';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Lucía', 'León Marín', NULL, 'Carrer del Montseny Blau 43', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'user034';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Manuel', 'Marín Montes', NULL, 'Carrer de l’Albufera Nova 44', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'user035';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marc', 'Martínez Ortega', NULL, 'Carrer del Túria Vell 45', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'user036';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marcos', 'Molina Ramírez', NULL, 'Calle del Guadalquivir Alto 46', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'user037';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'María', 'Moreno Sáez', NULL, 'Calle de la Giralda Clara 47', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'user038';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Martín', 'Nieto Vargas', NULL, 'Calle del Ebro Interior 48', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'user039';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Mateo', 'Ortiz Cabrera', NULL, 'Calle del Mediterráneo Sur 49', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'user040';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marta', 'Peña Díaz', NULL, 'Avenida de la Huerta Nueva 50', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'user041';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Miguel', 'Ramírez Gallardo', NULL, 'Carrer de la Serra Blanca 51', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'user042';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nadia', 'Rodríguez Hernández', NULL, 'Calle del Atlántico Claro 52', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'user043';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nerea', 'Ruiz Marín', NULL, 'Calle de la Costa Serena 53', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'user044';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nicolás', 'Santiago Montes', NULL, 'Calle del Nervión Verde 54', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'user045';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Noelia', 'Suárez Ortega', NULL, 'Rúa do Atlántico Norte 55', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'user046';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Óscar', 'Vázquez Ramírez', NULL, 'Calle del Pisuerga Nuevo 56', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'user047';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Pablo', 'Álvarez Sáez', NULL, 'Rúa das Illas Atlánticas 57', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'user048';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Paula', 'Cabrera Vargas', NULL, 'Calle del Cantábrico Norte 58', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'user049';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Raúl', 'Castro Cabrera', NULL, 'Calle de Sierra Clara 59', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'user050';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rebeca', 'Delgado Díaz', NULL, 'Avenida del Teide Alto 60', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'user051';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rocío', 'Durán Gallardo', NULL, 'Calle de la Sierra Morena 61', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'user052';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Samuel', 'Flores Hernández', NULL, 'Calle de Navarra Central 62', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'user053';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sara', 'García Marín', NULL, 'Calle de la Bahía Alta 63', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'user054';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sergio', 'González Montes', NULL, 'Calle del Tormes Claro 64', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'user055';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Silvia', 'Hernández Ortega', NULL, 'Calle de los Cigarrales Nuevos 65', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'user056';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sofía', 'Lara Ramírez', NULL, 'Calle del Arlanzón Norte 66', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'user057';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Tomás', 'Lozano Sáez', NULL, 'Calle del Ebro Riojano 67', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'user058';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Valeria', 'Martín Vargas', NULL, 'Calle del Naranco Nuevo 68', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'user059';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Víctor', 'Méndez Cabrera', NULL, 'Avenida de la Bahía Serena 69', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'user060';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Adrián', 'Morales Díaz', NULL, 'Calle del Prado Nuevo 70', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'user061';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alba', 'Navarro Gallardo', NULL, 'Avenida de la Dehesa Alta 71', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'user062';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alejandro', 'Ortega Hernández', NULL, 'Carrer de la Marina Nova 72', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'user063';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alicia', 'Pastor Marín', NULL, 'Carrer del Montseny Blau 73', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'user064';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Álvaro', 'Prieto Montes', NULL, 'Carrer de l’Albufera Nova 74', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'user065';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Ana', 'Reyes Ortega', NULL, 'Carrer del Túria Vell 75', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'user066';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Andrés', 'Rubio Ramírez', NULL, 'Calle del Guadalquivir Alto 76', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'user067';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Beatriz', 'Sánchez Sáez', NULL, 'Calle de la Giralda Clara 77', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'user068';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Bruno', 'Serrano Vargas', NULL, 'Calle del Ebro Interior 78', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'user069';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carla', 'Vargas Cabrera', NULL, 'Calle del Mediterráneo Sur 79', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'user070';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carlos', 'Alonso Díaz', NULL, 'Avenida de la Huerta Nueva 80', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'user071';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Clara', 'Blanco Gallardo', NULL, 'Carrer de la Serra Blanca 81', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'user072';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniel', 'Campos Hernández', NULL, 'Calle del Atlántico Claro 82', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'user073';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniela', 'Crespo Marín', NULL, 'Calle de la Costa Serena 83', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'user074';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'David', 'Domínguez Montes', NULL, 'Calle del Nervión Verde 84', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'user075';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Diego', 'Fernández Ortega', NULL, 'Rúa do Atlántico Norte 85', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'user076';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elena', 'Gallardo Ramírez', NULL, 'Calle del Pisuerga Nuevo 86', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'user077';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elías', 'Gómez Sáez', NULL, 'Rúa das Illas Atlánticas 87', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'user078';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Eva', 'Gutiérrez Vargas', NULL, 'Calle del Cantábrico Norte 88', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'user079';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Fernando', 'Jiménez Cabrera', NULL, 'Calle de Sierra Clara 89', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'user080';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gabriel', 'Lorenzo Díaz', NULL, 'Avenida del Teide Alto 90', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'user081';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gema', 'Márquez Gallardo', NULL, 'Calle de la Sierra Morena 91', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'user082';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Guillermo', 'Medina Hernández', NULL, 'Calle de Navarra Central 92', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'user083';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Héctor', 'Montes Marín', NULL, 'Calle de la Bahía Alta 93', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'user084';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Irene', 'Moya Montes', NULL, 'Calle del Tormes Claro 94', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'user085';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Iván', 'Núñez Ortega', NULL, 'Calle de los Cigarrales Nuevos 95', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'user086';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Javier', 'Pascual Ramírez', NULL, 'Calle del Arlanzón Norte 96', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'user087';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jimena', 'Pérez Sáez', NULL, 'Calle del Ebro Riojano 97', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'user088';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jorge', 'Ramos Vargas', NULL, 'Calle del Naranco Nuevo 98', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'user089';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Julia', 'Romero Cabrera', NULL, 'Avenida de la Bahía Serena 99', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'user090';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Laura', 'Sáez Díaz', NULL, 'Calle del Prado Nuevo 10', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'user091';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leire', 'Sanz Gallardo', NULL, 'Avenida de la Dehesa Alta 11', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'user092';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leo', 'Torres Hernández', NULL, 'Carrer de la Marina Nova 12', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'user093';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Lucía', 'Vega Marín', NULL, 'Carrer del Montseny Blau 13', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'user094';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Manuel', 'Benítez Montes', NULL, 'Carrer de l’Albufera Nova 14', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'user095';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marc', 'Calvo Ortega', NULL, 'Carrer del Túria Vell 15', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'user096';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marcos', 'Cortés Ramírez', NULL, 'Calle del Guadalquivir Alto 16', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'user097';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'María', 'Díaz Sáez', NULL, 'Calle de la Giralda Clara 17', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'user098';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Martín', 'Esteban Vargas', NULL, 'Calle del Ebro Interior 18', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'user099';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Mateo', 'Fuentes Cabrera', NULL, 'Calle del Mediterráneo Sur 19', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'user100';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marta', 'Giménez Díaz', NULL, 'Avenida de la Huerta Nueva 20', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'user101';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Miguel', 'Guerrero Gallardo', NULL, 'Carrer de la Serra Blanca 21', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'user102';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nadia', 'Iglesias Hernández', NULL, 'Calle del Atlántico Claro 22', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'user103';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nerea', 'León Marín', NULL, 'Calle de la Costa Serena 23', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'user104';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nicolás', 'Marín Montes', NULL, 'Calle del Nervión Verde 24', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'user105';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Noelia', 'Martínez Ortega', NULL, 'Rúa do Atlántico Norte 25', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'user106';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Óscar', 'Molina Ramírez', NULL, 'Calle del Pisuerga Nuevo 26', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'user107';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Pablo', 'Moreno Sáez', NULL, 'Rúa das Illas Atlánticas 27', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'user108';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Paula', 'Nieto Vargas', NULL, 'Calle del Cantábrico Norte 28', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'user109';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Raúl', 'Ortiz Cabrera', NULL, 'Calle de Sierra Clara 29', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'user110';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rebeca', 'Peña Díaz', NULL, 'Avenida del Teide Alto 30', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'user111';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rocío', 'Ramírez Gallardo', NULL, 'Calle de la Sierra Morena 31', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'user112';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Samuel', 'Rodríguez Hernández', NULL, 'Calle de Navarra Central 32', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'user113';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sara', 'Ruiz Marín', NULL, 'Calle de la Bahía Alta 33', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'user114';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sergio', 'Santiago Montes', NULL, 'Calle del Tormes Claro 34', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'user115';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Silvia', 'Suárez Ortega', NULL, 'Calle de los Cigarrales Nuevos 35', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'user116';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sofía', 'Vázquez Ramírez', NULL, 'Calle del Arlanzón Norte 36', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'user117';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Tomás', 'Álvarez Sáez', NULL, 'Calle del Ebro Riojano 37', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'user118';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Valeria', 'Cabrera Vargas', NULL, 'Calle del Naranco Nuevo 38', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'user119';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Víctor', 'Castro Cabrera', NULL, 'Avenida de la Bahía Serena 39', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'user120';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Adrián', 'Delgado Díaz', NULL, 'Calle del Prado Nuevo 40', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'guest121';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alba', 'Durán Gallardo', NULL, 'Avenida de la Dehesa Alta 41', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'guest122';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alejandro', 'Flores Hernández', NULL, 'Carrer de la Marina Nova 42', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'guest123';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alicia', 'García Marín', NULL, 'Carrer del Montseny Blau 43', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'guest124';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Álvaro', 'González Montes', NULL, 'Carrer de l’Albufera Nova 44', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'guest125';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Ana', 'Hernández Ortega', NULL, 'Carrer del Túria Vell 45', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'guest126';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Andrés', 'Lara Ramírez', NULL, 'Calle del Guadalquivir Alto 46', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'guest127';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Beatriz', 'Lozano Sáez', NULL, 'Calle de la Giralda Clara 47', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'guest128';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Bruno', 'Martín Vargas', NULL, 'Calle del Ebro Interior 48', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'guest129';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carla', 'Méndez Cabrera', NULL, 'Calle del Mediterráneo Sur 49', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'guest130';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carlos', 'Morales Díaz', NULL, 'Avenida de la Huerta Nueva 50', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'guest131';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Clara', 'Navarro Gallardo', NULL, 'Carrer de la Serra Blanca 51', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'guest132';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniel', 'Ortega Hernández', NULL, 'Calle del Atlántico Claro 52', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'guest133';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniela', 'Pastor Marín', NULL, 'Calle de la Costa Serena 53', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'guest134';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'David', 'Prieto Montes', NULL, 'Calle del Nervión Verde 54', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'guest135';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Diego', 'Reyes Ortega', NULL, 'Rúa do Atlántico Norte 55', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'guest136';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elena', 'Rubio Ramírez', NULL, 'Calle del Pisuerga Nuevo 56', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'guest137';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elías', 'Sánchez Sáez', NULL, 'Rúa das Illas Atlánticas 57', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'guest138';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Eva', 'Serrano Vargas', NULL, 'Calle del Cantábrico Norte 58', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'guest139';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Fernando', 'Vargas Cabrera', NULL, 'Calle de Sierra Clara 59', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'guest140';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gabriel', 'Alonso Díaz', NULL, 'Avenida del Teide Alto 60', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'guest141';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gema', 'Blanco Gallardo', NULL, 'Calle de la Sierra Morena 61', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'guest142';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Guillermo', 'Campos Hernández', NULL, 'Calle de Navarra Central 62', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'guest143';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Héctor', 'Crespo Marín', NULL, 'Calle de la Bahía Alta 63', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'guest144';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Irene', 'Domínguez Montes', NULL, 'Calle del Tormes Claro 64', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'guest145';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Iván', 'Fernández Ortega', NULL, 'Calle de los Cigarrales Nuevos 65', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'guest146';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Javier', 'Gallardo Ramírez', NULL, 'Calle del Arlanzón Norte 66', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'guest147';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jimena', 'Gómez Sáez', NULL, 'Calle del Ebro Riojano 67', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'guest148';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jorge', 'Gutiérrez Vargas', NULL, 'Calle del Naranco Nuevo 68', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'guest149';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Julia', 'Jiménez Cabrera', NULL, 'Avenida de la Bahía Serena 69', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'guest150';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Laura', 'Lorenzo Díaz', NULL, 'Calle del Prado Nuevo 70', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'guest151';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leire', 'Márquez Gallardo', NULL, 'Avenida de la Dehesa Alta 71', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'guest152';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leo', 'Medina Hernández', NULL, 'Carrer de la Marina Nova 72', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'guest153';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Lucía', 'Montes Marín', NULL, 'Carrer del Montseny Blau 73', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'guest154';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Manuel', 'Moya Montes', NULL, 'Carrer de l’Albufera Nova 74', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'guest155';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marc', 'Núñez Ortega', NULL, 'Carrer del Túria Vell 75', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'guest156';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marcos', 'Pascual Ramírez', NULL, 'Calle del Guadalquivir Alto 76', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'guest157';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'María', 'Pérez Sáez', NULL, 'Calle de la Giralda Clara 77', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'guest158';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Martín', 'Ramos Vargas', NULL, 'Calle del Ebro Interior 78', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'guest159';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Mateo', 'Romero Cabrera', NULL, 'Calle del Mediterráneo Sur 79', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'guest160';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marta', 'Sáez Díaz', NULL, 'Avenida de la Huerta Nueva 80', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'guest161';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Miguel', 'Sanz Gallardo', NULL, 'Carrer de la Serra Blanca 81', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'guest162';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nadia', 'Torres Hernández', NULL, 'Calle del Atlántico Claro 82', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'guest163';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nerea', 'Vega Marín', NULL, 'Calle de la Costa Serena 83', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'guest164';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nicolás', 'Benítez Montes', NULL, 'Calle del Nervión Verde 84', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'guest165';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Noelia', 'Calvo Ortega', NULL, 'Rúa do Atlántico Norte 85', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'guest166';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Óscar', 'Cortés Ramírez', NULL, 'Calle del Pisuerga Nuevo 86', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'guest167';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Pablo', 'Díaz Sáez', NULL, 'Rúa das Illas Atlánticas 87', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'guest168';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Paula', 'Esteban Vargas', NULL, 'Calle del Cantábrico Norte 88', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'guest169';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Raúl', 'Fuentes Cabrera', NULL, 'Calle de Sierra Clara 89', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'guest170';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rebeca', 'Giménez Díaz', NULL, 'Avenida del Teide Alto 90', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'guest171';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rocío', 'Guerrero Gallardo', NULL, 'Calle de la Sierra Morena 91', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'guest172';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Samuel', 'Iglesias Hernández', NULL, 'Calle de Navarra Central 92', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'guest173';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sara', 'León Marín', NULL, 'Calle de la Bahía Alta 93', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'guest174';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sergio', 'Marín Montes', NULL, 'Calle del Tormes Claro 94', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'guest175';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Silvia', 'Martínez Ortega', NULL, 'Calle de los Cigarrales Nuevos 95', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'guest176';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sofía', 'Molina Ramírez', NULL, 'Calle del Arlanzón Norte 96', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'guest177';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Tomás', 'Moreno Sáez', NULL, 'Calle del Ebro Riojano 97', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'guest178';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Valeria', 'Nieto Vargas', NULL, 'Calle del Naranco Nuevo 98', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'guest179';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Víctor', 'Ortiz Cabrera', NULL, 'Avenida de la Bahía Serena 99', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'guest180';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Adrián', 'Peña Díaz', NULL, 'Calle del Prado Nuevo 10', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'guest181';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alba', 'Ramírez Gallardo', NULL, 'Avenida de la Dehesa Alta 11', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'guest182';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alejandro', 'Rodríguez Hernández', NULL, 'Carrer de la Marina Nova 12', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'guest183';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Alicia', 'Ruiz Marín', NULL, 'Carrer del Montseny Blau 13', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'guest184';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Álvaro', 'Santiago Montes', NULL, 'Carrer de l’Albufera Nova 14', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'guest185';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Ana', 'Suárez Ortega', NULL, 'Carrer del Túria Vell 15', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'guest186';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Andrés', 'Vázquez Ramírez', NULL, 'Calle del Guadalquivir Alto 16', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'guest187';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Beatriz', 'Álvarez Sáez', NULL, 'Calle de la Giralda Clara 17', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'guest188';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Bruno', 'Cabrera Vargas', NULL, 'Calle del Ebro Interior 18', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'guest189';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carla', 'Castro Cabrera', NULL, 'Calle del Mediterráneo Sur 19', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'guest190';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Carlos', 'Delgado Díaz', NULL, 'Avenida de la Huerta Nueva 20', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'guest191';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Clara', 'Durán Gallardo', NULL, 'Carrer de la Serra Blanca 21', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'guest192';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniel', 'Flores Hernández', NULL, 'Calle del Atlántico Claro 22', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'guest193';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Daniela', 'García Marín', NULL, 'Calle de la Costa Serena 23', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'guest194';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'David', 'González Montes', NULL, 'Calle del Nervión Verde 24', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'guest195';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Diego', 'Hernández Ortega', NULL, 'Rúa do Atlántico Norte 25', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'guest196';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elena', 'Lara Ramírez', NULL, 'Calle del Pisuerga Nuevo 26', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'guest197';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Elías', 'Lozano Sáez', NULL, 'Rúa das Illas Atlánticas 27', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'guest198';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Eva', 'Martín Vargas', NULL, 'Calle del Cantábrico Norte 28', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'guest199';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Fernando', 'Méndez Cabrera', NULL, 'Calle de Sierra Clara 29', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'guest200';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gabriel', 'Morales Díaz', NULL, 'Avenida del Teide Alto 30', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'guest201';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Gema', 'Navarro Gallardo', NULL, 'Calle de la Sierra Morena 31', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'guest202';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Guillermo', 'Ortega Hernández', NULL, 'Calle de Navarra Central 32', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'guest203';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Héctor', 'Pastor Marín', NULL, 'Calle de la Bahía Alta 33', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'guest204';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Irene', 'Prieto Montes', NULL, 'Calle del Tormes Claro 34', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'guest205';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Iván', 'Reyes Ortega', NULL, 'Calle de los Cigarrales Nuevos 35', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'guest206';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Javier', 'Rubio Ramírez', NULL, 'Calle del Arlanzón Norte 36', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'guest207';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jimena', 'Sánchez Sáez', NULL, 'Calle del Ebro Riojano 37', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'guest208';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Jorge', 'Serrano Vargas', NULL, 'Calle del Naranco Nuevo 38', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'guest209';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Julia', 'Vargas Cabrera', NULL, 'Avenida de la Bahía Serena 39', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'guest210';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Laura', 'Alonso Díaz', NULL, 'Calle del Prado Nuevo 40', 'Madrid', '28001', 'ES'
FROM users
WHERE username = 'guest211';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leire', 'Blanco Gallardo', NULL, 'Avenida de la Dehesa Alta 41', 'Madrid', '28023', 'ES'
FROM users
WHERE username = 'guest212';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Leo', 'Campos Hernández', NULL, 'Carrer de la Marina Nova 42', 'Barcelona', '08012', 'ES'
FROM users
WHERE username = 'guest213';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Lucía', 'Crespo Marín', NULL, 'Carrer del Montseny Blau 43', 'Barcelona', '08027', 'ES'
FROM users
WHERE username = 'guest214';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Manuel', 'Domínguez Montes', NULL, 'Carrer de l’Albufera Nova 44', 'Valencia', '46017', 'ES'
FROM users
WHERE username = 'guest215';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marc', 'Fernández Ortega', NULL, 'Carrer del Túria Vell 45', 'Valencia', '46022', 'ES'
FROM users
WHERE username = 'guest216';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marcos', 'Gallardo Ramírez', NULL, 'Calle del Guadalquivir Alto 46', 'Sevilla', '41013', 'ES'
FROM users
WHERE username = 'guest217';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'María', 'Gómez Sáez', NULL, 'Calle de la Giralda Clara 47', 'Sevilla', '41020', 'ES'
FROM users
WHERE username = 'guest218';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Martín', 'Gutiérrez Vargas', NULL, 'Calle del Ebro Interior 48', 'Zaragoza', '50018', 'ES'
FROM users
WHERE username = 'guest219';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Mateo', 'Jiménez Cabrera', NULL, 'Calle del Mediterráneo Sur 49', 'Málaga', '29016', 'ES'
FROM users
WHERE username = 'guest220';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Marta', 'Lorenzo Díaz', NULL, 'Avenida de la Huerta Nueva 50', 'Murcia', '30009', 'ES'
FROM users
WHERE username = 'guest221';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Miguel', 'Márquez Gallardo', NULL, 'Carrer de la Serra Blanca 51', 'Palma', '07013', 'ES'
FROM users
WHERE username = 'guest222';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nadia', 'Medina Hernández', NULL, 'Calle del Atlántico Claro 52', 'Las Palmas de Gran Canaria', '35016', 'ES'
FROM users
WHERE username = 'guest223';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nerea', 'Montes Marín', NULL, 'Calle de la Costa Serena 53', 'Alicante', '03008', 'ES'
FROM users
WHERE username = 'guest224';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Nicolás', 'Moya Montes', NULL, 'Calle del Nervión Verde 54', 'Bilbao', '48014', 'ES'
FROM users
WHERE username = 'guest225';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Noelia', 'Núñez Ortega', NULL, 'Rúa do Atlántico Norte 55', 'A Coruña', '15008', 'ES'
FROM users
WHERE username = 'guest226';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Óscar', 'Pascual Ramírez', NULL, 'Calle del Pisuerga Nuevo 56', 'Valladolid', '47014', 'ES'
FROM users
WHERE username = 'guest227';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Pablo', 'Pérez Sáez', NULL, 'Rúa das Illas Atlánticas 57', 'Vigo', '36210', 'ES'
FROM users
WHERE username = 'guest228';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Paula', 'Ramos Vargas', NULL, 'Calle del Cantábrico Norte 58', 'Gijón', '33212', 'ES'
FROM users
WHERE username = 'guest229';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Raúl', 'Romero Cabrera', NULL, 'Calle de Sierra Clara 59', 'Granada', '18015', 'ES'
FROM users
WHERE username = 'guest230';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rebeca', 'Sáez Díaz', NULL, 'Avenida del Teide Alto 60', 'Tenerife', '38009', 'ES'
FROM users
WHERE username = 'guest231';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Rocío', 'Sanz Gallardo', NULL, 'Calle de la Sierra Morena 61', 'Córdoba', '14011', 'ES'
FROM users
WHERE username = 'guest232';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Samuel', 'Torres Hernández', NULL, 'Calle de Navarra Central 62', 'Pamplona', '31008', 'ES'
FROM users
WHERE username = 'guest233';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sara', 'Vega Marín', NULL, 'Calle de la Bahía Alta 63', 'Santander', '39012', 'ES'
FROM users
WHERE username = 'guest234';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sergio', 'Benítez Montes', NULL, 'Calle del Tormes Claro 64', 'Salamanca', '37005', 'ES'
FROM users
WHERE username = 'guest235';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Silvia', 'Calvo Ortega', NULL, 'Calle de los Cigarrales Nuevos 65', 'Toledo', '45005', 'ES'
FROM users
WHERE username = 'guest236';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Sofía', 'Cortés Ramírez', NULL, 'Calle del Arlanzón Norte 66', 'Burgos', '09006', 'ES'
FROM users
WHERE username = 'guest237';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Tomás', 'Díaz Sáez', NULL, 'Calle del Ebro Riojano 67', 'Logroño', '26007', 'ES'
FROM users
WHERE username = 'guest238';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Valeria', 'Esteban Vargas', NULL, 'Calle del Naranco Nuevo 68', 'Oviedo', '33011', 'ES'
FROM users
WHERE username = 'guest239';

INSERT IGNORE INTO user_profiles (user_id, first_name, last_name, phone, address_line, city, postal_code, country_code)
SELECT id, 'Víctor', 'Fuentes Cabrera', NULL, 'Avenida de la Bahía Serena 69', 'Cádiz', '11009', 'ES'
FROM users
WHERE username = 'guest240';
