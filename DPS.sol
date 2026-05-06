// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Contract {

    address public owner;
    address public bankAddress;
    address public InsuranceAddress;

    // Субъекты
    enum Role {
        none, 
        driver,
        user,
        police,
        insurance,
        bank,
        car // Объект
    }

    // Структура пользователя
    struct User {
        string login;
        string password;
    }

    // Характеристики ТС
    struct Car {
        string category;        // Категория (A, B, C)
        uint256 marketValue;    // Рыночная стоимость (Рс, eth)
        uint256 serviceLife;    // Срок эксплуатации (Сэ, лет)  
    }

    // Характеристики водителя
    struct Driver {
        string FIO;                // Фио
        uint256 VodPrava;          // Водительские права
        uint256 drivingStartYear;  // Год начала стажа
        uint256 numberAccident;    // Количество ДТП
        uint256 numberUnpaidFines; // Количество неоплаченных штрафов
        uint256 insurancePremium;  // Страховой взнос
        uint256 currentBalance;    // Текущий баланс
        uint256 drivingExperience; // Водительский стаж
    }

    // Характеристика водительских прав
    struct VodPrava {
        uint256 number;           // Номер водительского удостоверения
        uint256 expiryDate;       // Срок действия
        string category;          // Категория ТС (A, B, C, D, etc.)
        uint256 issueDate;        // Дата выдачи
        string driver;            // Водитель
        uint256 currentTime;    //Конец действия 
    }

    // Характеристика штрафа
    struct Fine {
        uint256 price;            // Стоимость
        uint256 startDate;         // Дата получения штрафа
        uint256 expiryDateFine;    // Срок оплаты штрафа
    }

    // Характеристика ДТП
    struct Accident {
        string date;              // Дата ДТП
        string place;             // Место ДТП
        string description;       // Описание ДТП
    }

    // Характеристика страховки
    struct Insurance {
        uint256 price;            // Стоимость страховки
        uint256 term;             // Срок страховки
        uint256 marketValueCar;   // Стоимость страховки автомобиля
        uint256 marketValue;      // Рыночная стоимость (Рс, eth)
    }

    mapping(address => VodPrava) public MVodPrava;
    mapping(address => Role) public Roles;
    mapping(address => Car[]) public Cars;
    mapping(address => Fine[]) public Fines;
    mapping(address => User) public Users;
    mapping(address => uint256) public balances;
    mapping(address => Driver) public Drivers;
    mapping(address => Accident[]) public Accidents;
    mapping(address => Insurance) public Insurances;

    modifier ChekDriver() {
        require(Roles[msg.sender] == Role.driver, "Not driver");
        _;
    }

    modifier Checkpolice() {
        require(Roles[msg.sender] == Role.police, "Not police");
        _;
    }

    modifier CheckBank() {
        require(Roles[msg.sender] == Role.bank, "Not bank");
        _;
    }
 
    modifier CheckTime() {
        require(MVodPrava[msg.sender].expiryDate >= block.timestamp, "Time end");
        _;
    }

    enum Category { A, B, C }

    mapping(address => Category) public userCategory;
     
    function setCategory(Category category) public {
    userCategory[msg.sender] = category;
    }


    constructor() {
        // БАНК
        bankAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        Roles[bankAddress] = Role.bank;

        // СТРАХОВАЯ
        InsuranceAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        Roles[InsuranceAddress] = Role.insurance;

        owner = msg.sender;
    }

    // Функция для просмотра баланса банка
    function getBalanceBank() public view returns (uint256) {
        return address(bankAddress).balance;
    }

    // Функция для просмотра баланса страховой
    function getBalanceInsurance() public view returns (uint256) {
        return address(InsuranceAddress).balance;
    }

    //смотреть роль
    function  getRole() public view returns(Role) {
        return Roles[msg.sender];
    }

    //Функция для просмотра ВУ
    function getVodPrava() public view returns (VodPrava memory) {
    return MVodPrava[msg.sender];
    }

    //Функция для просмотра машины 
    function getCars() public view returns (Car[] memory) {
    return Cars[msg.sender];
    }

    //Функция для просмотра штрафов
    function getFines() public view returns (Fine[] memory) {
    return Fines[msg.sender];
    }

    //Функция для просмотра ДТП
    function getAccident() public view returns (Accident[] memory) {
    return Accidents[msg.sender];
    }

    //Функция для просмотра страховки
    function getInsurance() public view returns (Insurance memory) {
    return Insurances[msg.sender];
    }

    //Функция для просмотра кол-во машин
    function getCarsCount() public view returns (uint) {
    return Cars[msg.sender].length;
    }

    //Функция для просмотра кол-во штрафов
    function getFinesCount() public view returns (uint) {
    return Fines[msg.sender].length;
    }

    // Функционал для водителя

    // Функция для регистрации пользователя
    function registr(string memory _login, string memory _password) public {
        require(keccak256(abi.encode(Users[msg.sender].login)) == keccak256(abi.encode("")), unicode"пользователь уже зарегистрирован");
        require(bytes(_login).length != 0, unicode"логин не может быть пустым");
        Users[msg.sender] = User(_login, _password);
        Roles[msg.sender] = Role.driver;
    }

    // Функция для входа пользователя
    function authorization(string memory _login, string memory _password) public view returns (string memory) {
        require(keccak256(abi.encode(_login)) == keccak256(abi.encode(Users[msg.sender].login)), unicode"неправильный логин");
        require(keccak256(abi.encode(_password)) == keccak256(abi.encode(Users[msg.sender].password)), unicode"неверный пароль");
        return Users[msg.sender].login;
    }

    // Функция для добавления водительского удостоверения
    function addVodPrava(uint256 _number, uint256 _expiryDate, string memory _category, uint256 _issueDate, string memory _driver, uint256 _currentTime) public {
        require(_number > 0, unicode"Идентификационный номер не может быть пустым");
        MVodPrava[msg.sender] = VodPrava(_number, _expiryDate, _category, _issueDate, _driver, _currentTime);
    }
    

    // Запрос на регистрацию транспортного средства
    function registrCar(string memory _category, uint _marketValue, uint _serviceLife) public  {
        require(bytes(_category).length > 0, unicode"Категория не может быть пустой");
        require(_marketValue > 0, unicode"Рыночная стоимость должна быть больше 0");
        require(keccak256(abi.encode(_category)) == keccak256(abi.encode(MVodPrava[msg.sender].category)), unicode"Категория транспортного средства не соответствует категории водительского удостоверения");

        Cars[msg.sender].push(Car(_category, _marketValue, _serviceLife));
    }

    // Запрос на продление срока действия водительского удостоверения
    function extendVodPrava(uint _newExpiryDate) public CheckTime {
        require(MVodPrava[msg.sender].number > 0, unicode"Не найдено действительных водительских прав");
        require(_newExpiryDate > MVodPrava[msg.sender].expiryDate, unicode"Новый срок годности должен быть больше чем прошлый");

        MVodPrava[msg.sender].expiryDate = _newExpiryDate;
    }


    //Функция для пополнения счёта
    function deposit() public payable {
    balances[msg.sender] += msg.value;
    }


    // Функция перевода
    function transfer(address to, uint256 _price) external {
        require(to != address(0), unicode"Неверный адрес получателя");
        require(balances[msg.sender] >= _price, unicode"Недостаточно средств");
        require(msg.sender != to, unicode"Вы не можете перевести сами");
        require(Drivers[msg.sender].numberUnpaidFines > 0, "No fines");

        balances[msg.sender] -= _price;
        balances[to] += _price;

        if (Drivers[msg.sender].numberUnpaidFines > 0) {
        Drivers[msg.sender].numberUnpaidFines--;
        }

    }

    // Функция для страховки
    function creatInsurance(uint256 _marketValueCar, uint256 _price, uint256 _term, uint _marketValue) public {
        require(_marketValueCar > 0, unicode"Стоимость не может быть отрицательной");
        require(_price > 0, unicode"Страховая премия не может быть отрицательной");
        require(MVodPrava[msg.sender].number > 0, unicode"Нет действительных водительских прав");
        require(_term > 0, unicode"Срок действия не может быть отрицательным");
        require(_marketValueCar == _marketValue, unicode"Указана неверная цена");

        Insurances[msg.sender] = Insurance(_price, _term, _marketValueCar, _marketValue);
    }

    // ДПС

    //Функция для регистрации ДПСника
        function setDPS(address _addr) public {
        require(msg.sender == owner, "Not owner");
    Roles[_addr] = Role.police;
    }


    // Функция для подтверждения водительских прав
    function confirmsVodPrava(address _driver, uint256 _number, uint256 _expiryDate, string memory _category, uint256 _issueDate, uint256 _currentTime) public Checkpolice {
        require(_number > 0, unicode"Номер не может быть пустым");
        require(_expiryDate > block.timestamp, unicode"Срок действия истек");
        require(bytes(Users[_driver].login).length > 0, unicode"Водитель не зарегистрирован");

        uint256 time = block.timestamp + _currentTime;

        MVodPrava[_driver] = VodPrava(_number, _expiryDate, _category, _issueDate, Drivers[_driver].FIO, time);
    }

    // Функция для создания штрафа
    function createFine(address _driver, uint256 _price, uint _startDate, uint _expiryDate) public Checkpolice {
        Fines[_driver].push(Fine(_price, _startDate, _expiryDate));
        Drivers[_driver].numberUnpaidFines++;
    }

    // Функция для создания отметки ДТП
    function createDTP(address _driver, string memory _date, string memory _description, string memory _place) public Checkpolice {
        Accidents[_driver].push(Accident(_date, _description, _place));
    }

    // Страховая

    // Оформление страховки/расчёт страхового взноса                                 чуть чуть переписал гпт 
    function calculationInsurance(uint256 _carIndex) public view returns (uint256) {
    require(_carIndex < Cars[msg.sender].length, unicode"Машина не существует");

    Car storage car = Cars[msg.sender][_carIndex];
    Driver storage driver = Drivers[msg.sender];

    uint256 Rs = car.marketValue; 
    uint256 Ce = car.serviceLife;
    uint256 Shtr = driver.numberUnpaidFines;
    uint256 Dtp = driver.numberAccident;
    uint256 Vs = driver.drivingExperience;

    // (1 - Ce/10) * 10
    int256 temp = int256(10 - Ce);

    // модуль |...|
    if (temp < 0) {
        temp = -temp;
    }

    // итоговая формула
    int256 strVzn = (
        int256(Rs) * temp +   // Rs * |1 - Ce/10| * 10
        int256(2 * Shtr) +    // 0.2 * Штр
        int256(10 * Dtp) -    // ДТП
        int256(2 * Vs)        // 0.2 * Вс
    ) / 10;

    // защита от отрицательного результата
    if (strVzn < 0) {
        return 0;
    }

    return uint256(strVzn);
}

    //ВЫход
    function exit() public {
        Roles[msg.sender] = Role.none;
        }
}
