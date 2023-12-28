  # Todos os índices usados foram do tipo BTree 
  # Pois não houve a necessidade ao meu ver de usar outros indices como os de Hash por exemplo

  -- indices na tabela de vendas
 ALTER TABLE vendas ADD UNIQUE idx_nome_vendedor(Nome_vendedor) USING BTREE;
 ALTER TABLE vendas ADD UNIQUE idx_produto(Produto) USING BTREE;
 
 -- indices na tabela project
CREATE index idx_pname on project(Pname);
CREATE index idx_Dnum on project(Dnum);

-- indices de dept_location
CREATE INDEX idx_Dlocation on dept_locations(Dlocation);
CREATE INDEX idx_Dnumber on dept_locations(Dnumber);

-- indices de employee
CREATE INDEX idx_dname on employee(Dno);
 
-- indices de deoartment
CREATE INDEX idx_Dname on department(Dname);

CREATE VIEW departamento_com_mais_funcionarios
AS
SELECT Dname AS Nome_Departamento,COUNT(Dname) AS total_de_funcionarios
 FROM employee e JOIN department d ON (e.Dno = d.Dnumber) 
 GROUP BY Dname ORDER BY total_de_funcionarios DESC LIMIT 1;
 
CREATE VIEW departamentos_por_cidade
AS
SELECT Dname AS nome_departamento, Dlocation AS lugar_atuação 
FROM dept_locations dl 
JOIN department d ON(d.Dnumber = dl.Dnumber);

CREATE VIEW empregados_departamento
AS
SELECT CONCAT(e.Fname, " ",e.Minit,". ",e.Lname) AS Nome, Dname AS Departamento 
FROM employee e JOIN department d ON(e.Dno = d.Dnumber);


#action = 1 -> select
#action = 2 -> update
#action = 3 -> delete 
DELIMITER //
CREATE PROCEDURE proc_employees
(
    IN action INT,
    IN Fname VARCHAR(15),
    IN Minit CHAR(1),
    IN Lname VARCHAR(15),
    IN Ssn CHAR(9),
    IN Bdate DATE,
    IN Address VARCHAR(30),
    IN sex CHAR(1),
    IN Salary DECIMAL(10,2),
    IN Super_ssn CHAR(9),
    IN Dno INT
)
BEGIN
    DECLARE contadorDno INT;
    DECLARE contadorSsn INT;
    DECLARE existeWorksOn INT;
    DECLARE mensagem VARCHAR(40);

    IF action = 1 THEN
        SELECT * FROM employee;
    ELSEIF action = 2 THEN
        SELECT COUNT(d.Dnumber) INTO contadorDno FROM department d WHERE d.Dnumber = Dno;
        SELECT COUNT(e.Ssn) INTO contadorSsn FROM employee e WHERE e.Ssn = Ssn;
        
        IF contadorDno = 0 THEN
            SET mensagem = 'Esse departamento não existe';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensagem;
        END IF;
        
        IF contadorSsn = 0 THEN
            SET mensagem = 'Ssn não encontrado';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensagem;
        END IF;
        
        UPDATE employee SET 
        employee.Fname = Fname,
        employee.Minit = Minit,
        employee.Lname = Lname,
        employee.Ssn = Ssn,
        employee.Bdate = Bdate,
        employee.Address = Address,
        employee.sex = sex,
        employee.Salary = Salary,
        employee.Super_ssn = Super_ssn,
        employee.Dno= Dno
        WHERE employee.Ssn = Ssn;
        
    ELSEIF action = 3 THEN
        SELECT COUNT(e.Ssn) INTO contadorSsn FROM employee e WHERE e.Ssn = Ssn;
        SELECT COUNT(w.Essn) INTO existeWorksOn FROM works_on w WHERE w.Essn = Ssn;
        IF contadorSsn = 0 THEN
            SET mensagem = 'Ssn não encontrado';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensagem;
        END IF;
        IF existeWorksOn > 0 THEN  #deletar Relacionamento
           DELETE FROM works_on WHERE Essn = Ssn;
        END IF;
        DELETE FROM employee WHERE Ssn = Ssn;
    END IF;
END //
DELIMITER ;
