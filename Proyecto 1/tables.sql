CREATE DATABASE DB_Proyecto1;

USE DB_Proyecto1;

CREATE TABLE CATEGORIA (
    id_categoria INTEGER PRIMARY KEY,
    nombre VARCHAR(50)
);
CREATE TABLE PAIS (
    id_pais INTEGER PRIMARY KEY,
    nombre VARCHAR(50)
);
CREATE TABLE PRODUCTO (
    id_producto INTEGER PRIMARY KEY,
    nombre VARCHAR(100),
    precio FLOAT(2),
    id_categoria INTEGER,
    FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
);

CREATE TABLE VENDEDOR (
    id_vendedor INTEGER PRIMARY KEY,
    nombre VARCHAR(50),
    id_pais INTEGER,
    FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais)
);

CREATE TABLE CLIENTE (
    id_cliente INTEGER PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    tarjeta_credito VARCHAR(20),
    edad INTEGER,
    genero VARCHAR(1),
    salario FLOAT(2),
    id_pais INTEGER,
    FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais)
);

CREATE TABLE ORDEN_VENTA (
    id_orden INTEGER,
    linea_orden INTEGER,
	fecha_orden DATE,
    id_vendedor INTEGER,
    id_cliente INTEGER,
    id_producto INTEGER,
    cantidad INTEGER,
    FOREIGN KEY (id_vendedor) REFERENCES VENDEDOR(id_vendedor),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
);
