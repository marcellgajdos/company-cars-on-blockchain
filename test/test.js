var HR = artifacts.require('HR');
var CF = artifacts.require('CarFactory');
var GAR = artifacts.require('Garage');
contract('GAR', function (accounts) {
    var gar;
    it('add employee', function () {
        return GAR.deployed().then(async (instance) => {
            gar = instance;
            await gar.HR_AddEmployee('John', 2, accounts[0]);
            await gar.HR_AddEmployee('Jack', 3, accounts[1]);
            return gar.HR_GetClearance('John');
        }).then(function (x) {
            assert(x == 2, "clearance corrupt");
            return gar.HR_GetAddress('John');
        }).then(function (x) {
            assert(x == accounts[0], "address corrupt")
        })

    });
    it('modify employee', function () {
        return GAR.deployed().then(async (instance) => {
            await gar.HR_ModifyEmployee('John', 1, accounts[2]);
            return gar.HR_GetClearance('John');
        }).then(function (x) {
            assert(x == 1, "clearance incorrect");
            return gar.HR_GetAddress('John');
        }).then(function (x) {
            assert(x == accounts[2], "address incorrect");
        })

    });
    it('remove employee', async () => {
        return GAR.deployed().then(async () => {
            await gar.HR_DeleteEmployee('John');
            assert(await gar.HR_IsEmployee('John') == false, "Removal fault");
        });
    });
    it('add car', async () => {
        return GAR.deployed().then(async () => {
            await gar.HR_AddEmployee('John', 1, accounts[0]);
            await gar.G_AddCar("ABC123", "Audi", "A8L", 20220315, 250000, 0, 2);
            await gar.G_AddCar("DEF456", "BMW", "M8", 20020315, 230000, 130, 1);
            await gar.G_AddCar("GHI789", "Fiat", "500", 20040315, 80000, 200, 5);
            return gar.G_GetMake("ABC123");
        }).then(function (x) {
            assert(x == "Audi", "first make incorrect");
            return gar.G_GetMake("DEF456");
        }).then(function (x) {
            assert(x == "BMW", "second make incorrect");
            return gar.G_GetModelID("DEF456");
        }).then(function (x) {
            assert(x == "M8", "second model incorrect");
            return gar.G_GetDateOfPurchase("DEF456");
        }).then(function (x) {
            assert(x == 20020315, "second date of purchase incorrect");
            return gar.G_GetCostOfPurchase("DEF456");
        }).then(function (x) {
            assert(x == 230000, "second cost of purchase incorrect");
            return gar.G_GetMilageWhenPurchased("DEF456");
        }).then(function (x) {
            assert(x == 130, "second milage when purchased incorrect");
            return gar.G_GetCategory("DEF456");
        }).then(function (x) {
            assert(x == 1, "second category incorrect");
        });
    });
    it('delete car', async () => {
        return GAR.deployed().then(async () => {
            await gar.G_DeleteCar("DEF456");
            return gar.G_GetDateOfPurchase("DEF456");//cannot be zero when a car is registered because of the date format
        }).then(function (x) {
            assert.equal(x, 0, "failed to delete car");
        });
    });
    it('pick car up', async () => {
        return GAR.deployed().then(async () => {
            await gar.G_SwitchAdmin(accounts[9]);
            await gar.G_AddCar("DEF456", "BMW", "M8", 20020315, 230000, 130, 1);
            await gar.G_PickupCar('John', 'ABC123', 100);//John picks up ABC123
            return gar.G_GetOccupied('ABC123');
        }).then(function (x) {
            assert.equal(x, 1, "occupied not modified")
            return gar.G_GetLastDriver('ABC123');
        }).then(function (x) {
            assert.equal(x, 'John', 'last driver not modified')
            return gar.G_GetCurrentMilage('ABC123');
        }).then(function (x) {
            assert.equal(x, 100, "milage not updated");
            return gar.G_GetDriverAddress("ABC123");
        }).then(function (x) {
            assert.equal(x, accounts[0], "Car token not transferred to employee");
        });
    });
    it('should not be able to pick car up with improper clearance', async () => {
        return GAR.deployed().then(async () => {
            await gar.HR_ModifyEmployee('Jack', 2, accounts[2]);
            await gar.G_PickupCar('Jack', 'DEF456', 100);//this car is category 1, Jack has clearance to 2
            return gar.G_GetOccupied("DEF456");
        }).then(function (x) {
            assert.equal(x, false, "car can be picked up with improper clearance");
        });
    });
    it('should not be able to pick car up with another car picked up', async () => {
        return GAR.deployed().then(async () => {
            await gar.G_PickupCar('John', 'GHI789', 150);//John has already took out DEF456 and has not dropped it off yet
            return gar.G_GetOccupied('GHI789');
        }).then(function (x) {
            assert.equal(x, false, "multiple cars can be picked up");
        });
    });
    it('should not be able to pick car up that is already occupied', async () => {
        return GAR.deployed().then(async () => {
            await gar.G_PickupCar('Jack', 'ABC123', 100);//picked up by John earlier
            return gar.G_GetLastDriver('ABC123');
        }).then(function (x) {
            assert.equal(x, 'John', "car can be snatched from another employee");//car needs to stay at John
            return gar.HR_GetDrivenCar('Jack');
        }).then(function (x) {
            assert.equal(x, "", "hascar falsely modified");//Jack should not have a car
        });
    });
    it('drop car off', async () => {
        return GAR.deployed().then(async () => {
            await gar.G_DropoffCar('John');//John holds ABC123
            return gar.HR_GetDrivenCar('John');
        }).then(function (x) {
            assert.equal(x, "", "drivenCar has not been reset");
            return gar.G_GetOccupied("ABC123");
        }).then(function (x) {
            assert.equal(x, false, "Car is still shown as occupied")
            return gar.G_GetDriverAddress("ABC123");
        }).then(function (y) {
            assert.equal(y, accounts[9], "Car token not transferred back")
        });
    });
});