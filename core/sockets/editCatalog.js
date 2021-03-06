var auth = require('../app_modules/auth');
var db = require('../app_modules/db');
var inv = require('../app_modules/inventory');

module.exports = function editCatalog(socket, app) {

  function checkMe(that, errMessage, callback)
  {
    auth.isAdmin(that.user).then(function(isAdmin)
    {
      if(!isAdmin)
      {
        console.error(that.user + errMessage);
        that.emit('alertMessage', 'You do not have admin privileges, if you do, please log in again');
        return false;
      }
      else {callback();}
      }).catch(console.error);
    }

    socket.on('inv.get', function(item){
      var that = this;
      var errMessage = ' attempted to get info of ' + item.callNum;
      checkMe(that, errMessage, function success()
      {
        inv.get(item.callNum).then(function(result) {
          that.emit('inv.info', result)
        });
      })
    });

    socket.on('deleteItem', function(delInfo)
    {
      var errMessage = ' attempted to get delete item ' + delInfo.callNum;
      var that = this;
      checkMe(this, errMessage, function success()
      {
        var client = db();
        client.query("DELETE FROM inventory WHERE call = $1;", [delInfo.callNum]);
        var del = "Item ["+ delInfo.callNum + "] was deleted";
        client.query("INSERT INTO item_history (call_number, type, who, date_changed, notes) VALUES ($1, 'Delete Item', $2, CURRENT_TIMESTAMP, $3) ",
        [delInfo.origCall, that.user, del ])
      })
    });

    socket.on('inv.create', function(edited)
    {
      var client = db();
      var data = edited.data;
      var that = this;
      inv.create(this.user, data.newCall, data).catch(function(e) {
        console.error(e);
        that.emit('alertMessage', 'There was an error creating the item.');
      });
    });

    socket.on('inv.update', function(edited)
    {
      var client = db();
      var that = this;
      var data = edited.data;

      inv.update(this.user, data.newCall, data).catch(function(e) {
        console.error(e);
        that.emit('alertMessage', 'There was an error updating the database.');
      });
    });

  };
