angular.module("app").run(["$templateCache", function($templateCache) {

  $templateCache.put("account.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    " <!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    " <!--<li><i class=\"fa fa-link fa-fw\"></i> Block Explorer</li>-->\n" +
    "<!--</ol>-->\n" +
    "<div class=\"header\">\n" +
    "\t<div class=\"col-sm-12\">\n" +
    "\t\t<h3 class=\"header-title\">{{accountName}}</h3>\n" +
    "\t\t\n" +
    "\t</div>\n" +
    "</div>\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\t<div>{{accountBalance}}, {{accountUnit}}</div>\n" +
    "\t<div>{{accountAddress}}</div>\n" +
    "\t<br>\n" +
    "\t<div class=\"pull-right\">\n" +
    "\t\t\t<button class=\"btn btn-primary\"><i class=\"fa fa-edit fa-lg fa-fw\"></i> Register</button>\n" +
    "\t\t</div>\n" +
    "\t<button class=\"btn btn-primary\"><i class=\"fa fa-file-excel-o fa-lg fa-fw\"></i> Issue assets</button>\n" +
    "</div>\n" +
    "\n" +
    "\n" +
    "<h4>Transaction History</h4>\n"
  );

  $templateCache.put("blocks.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    " <!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    " <!--<li><i class=\"fa fa-link fa-fw\"></i> Block Explorer</li>-->\n" +
    "<!--</ol>-->\n" +
    "<div class=\"header\">\n" +
    "\t<div class=\"col-sm-12\">\n" +
    "\t\t<h3 class=\"header-title\">Block Explorer</h3>\n" +
    "\t</div>\n" +
    "</div>\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\n" +
    "</div>\n"
  );

  $templateCache.put("contact.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    " <!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    " <!--<li><i class=\"fa fa-link fa-fw\"></i> Block Explorer</li>-->\n" +
    "<!--</ol>-->\n" +
    "<div class=\"header\">\n" +
    "\t<div class=\"col-sm-12\">\n" +
    "\t\t<h3 class=\"header-title\">{{contactName}}</h3>\n" +
    "\t</div>\n" +
    "</div>\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\t<div>{{contactAddress}}</div>\n" +
    "\tRegistration Date: 00/00/0000<br>\n" +
    "\tDelegate: No\n" +
    "</div>\n"
  );

  $templateCache.put("contacts.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    " <!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    " <!--<li><i class=\"fa fa-sign-out fa-fw\"></i> Contacts</li>-->\n" +
    "<!--</ol>-->\n" +
    "\n" +
    "<div class=\"header\">\n" +
    "\t<div class=\"col-md-12\">\n" +
    "\t\t<h3 class=\"header-title\">Contacts</h3>\n" +
    "\t\t<div class=\"pull-left\">\n" +
    "\t\t\t<button type=\"submit\" ng-click='newContactModal()' class=\"btn btn-primary\"><i class=\"fa fa-plus fa-fw\"></i> New</button>\n" +
    "\t\t</div>\n" +
    "\t\t<div class=\"pull-right\">\n" +
    "\t\t\t<input type=\"text\" class=\"form-control\" ng-model=\"filterOptions.filterText\" placeholder='Filter'>\n" +
    "\t\t</div>\n" +
    "\t</div>\n" +
    "</div>\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\n" +
    "\t<div>\n" +
    "        <div style=\"height: 600px; padding-top:6px\" ng-grid=\"gridOptions\"></div>    \n" +
    "    </div>\n" +
    "</div>\n" +
    "\n"
  );

  $templateCache.put("createwallet.html",
    "<br/>\n" +
    "<br/>\n" +
    "<div class=\"main-content\">\n" +
    "\n" +
    " <div class=\"header row\">\n" +
    "  <div class=\"col-md-12\">\n" +
    "    <img src=\"img/bs-double-trans.png\" class=\"img-responsive\">\n" +
    "    <br><br>\n" +
    "   <h3 class=\"header-title\">Create New BitShares XT Wallet</h3>\n" +
    "  </div>\n" +
    " </div>\n" +
    "<br/>\n" +
    " <form name=\"wform\" class=\"form-horizontal\" role=\"form\" ng-submit=\"submitForm(wform.$valid)\" novalidate>\n" +
    "<!--Name is set to default\n" +
    "  <div class=\"row\">\n" +
    "   <div class=\"col-md-12\">\n" +
    "    <h3>Name</h3>\n" +
    "\n" +
    "    <p>Your wallet name.  You can have multiple wallets on one</p>\n" +
    "\n" +
    "    <div class=\"form-group\" ng-class=\"{ 'has-error' : wform.wp.$invalid && !wform.wp.$pristine }\">\n" +
    "     <label for=\"wallet_name\" class=\"col-sm-2 control-label\">Name</label>\n" +
    "\n" +
    "     <div class=\"col-sm-6\">\n" +
    "      <input ng-model=\"wallet_name\" name=\"wp\" required class=\"form-control\" ng-pattern=\"/^[a-z][a-z0-9-]*$/\" id=\"wallet_name\"\n" +
    "             placeholder=\"Name\" autofocus ng-minlength=\"1\" ng-maxlength=\"63\">\n" +
    "      <p ng-show=\"wform.wp.$error.required\" class=\"help-block\">Name is required.</p>\n" +
    "      <p ng-show=\"wform.wp.$error.maxlength\" class=\"help-block\">Name can be at most 63 characters.</p>\n" +
    "      <p ng-show=\"wform.wp.$error.pattern\" class=\"help-block\">Name can only contain lowercase alphanumeric characters and dashes and must start with a letter.</p>\n" +
    "     </div>\n" +
    "    </div>\n" +
    "   </div>\n" +
    "  </div>\n" +
    "  -->\n" +
    "  <br/>\n" +
    "  <div class=\"row\">\n" +
    "   <div class=\"col-md-12\">\n" +
    "    <h3>Password</h3>\n" +
    "\n" +
    "    <p>Your password is manditory and controls when and how your funds may be spent. If you forget this\n" +
    "     password you will be unable to transfer your shares.</p>\n" +
    "\n" +
    "    <div class=\"form-group\" ng-class=\"{ 'has-error' : wform.sp.$invalid && !wform.sp.$pristine }\">\n" +
    "     <label for=\"spending_password\" class=\"col-sm-2 control-label\">Password</label>\n" +
    "\n" +
    "     <div class=\"col-sm-6\">\n" +
    "      <input ng-trim=\"false\" ng-model=\"spending_password\" name=\"sp\" type=\"password\" class=\"form-control\" id=\"spending_password\"\n" +
    "             placeholder=\"Password\"\n" +
    "             required autofocus ng-minlength=\"9\" ng-maxlength=\"255\">\n" +
    "\n" +
    "      <p ng-show=\"wform.sp.$error.minlength\" class=\"help-block\">Password is too short. It must be more than 8 characters.</p>\n" +
    "      <p ng-show=\"wform.sp.$error.maxlength\" class=\"help-block\">Password is too long. It can be at most 255 characters.</p>\n" +
    "      <p ng-show=\"wform.sp.$invalid && !wform.sp.$pristine\" class=\"help-block\">Password is required.</p>\n" +
    "     </div>\n" +
    "    </div>\n" +
    "    <div class=\"form-group\" ng-class=\"{ 'has-error' : wform.csp.$invalid && !wform.csp.$pristine }\">\n" +
    "     <label for=\"confirm_spending_password\" class=\"col-sm-2 control-label\">Confirm Password</label>\n" +
    "\n" +
    "     <div class=\"col-sm-6\">\n" +
    "      <input ng-trim=\"false\" ng-model=\"confirm_spending_password\" name=\"csp\" type=\"password\" class=\"form-control\"\n" +
    "             id=\"confirm_spending_password\"\n" +
    "             placeholder=\"Confirm Password\" required data-match=\"spending_password\">\n" +
    "\n" +
    "      <p ng-show=\"wform.csp.$error.match\" class=\"help-block\">Fields do not match.</p>\n" +
    "     </div>\n" +
    "    </div>\n" +
    "    <!--\n" +
    "    <div>\n" +
    "      <button class=\"btn btn-default btn-lg\" ng-click=\"isCollapsed = !isCollapsed\">Brain Wallet</button>\n" +
    "      <hr>\n" +
    "      <div collapse=\"isCollapsed\">\n" +
    "        <div class=\"well well-lg\">\n" +
    "          <div class=\"form-group\" ng-class=\"{ 'has-error' : wform.bp.$invalid && !wform.bp.$pristine }\">\n" +
    "           <label for=\"brain_passphrase\" class=\"col-sm-2 control-label\">Brain Passphrase</label>\n" +
    "\n" +
    "           <div class=\"col-sm-6\">\n" +
    "            <input ng-trim=\"false\" ng-model=\"brain_passphrase\" name=\"bp\" type=\"password\" class=\"form-control\" id=\"brain_passphrase\"\n" +
    "                   placeholder=\"Brain Passphrase\" autofocus ng-minlength=\"32\" ng-maxlength=\"255\">\n" +
    "\n" +
    "            <p ng-show=\"wform.bp.$error.minlength\" class=\"help-block\">Passphrase is too short. It must be at least 32 characters.</p>\n" +
    "            <p ng-show=\"wform.bp.$error.maxlength\" class=\"help-block\">Passphrase is too long. It can be at most 255 characters.</p>\n" +
    "           </div>\n" +
    "          </div>\n" +
    "          <div class=\"form-group\" ng-class=\"{ 'has-error' : wform.cbp.$invalid && !wform.cbp.$pristine }\">\n" +
    "           <label for=\"confirm_brain_passphrase\" class=\"col-sm-2 control-label\">Confirm Brain Passphrase</label>\n" +
    "\n" +
    "           <div class=\"col-sm-6\">\n" +
    "            <input ng-trim=\"false\" ng-model=\"confirm_brain_passphrase\" name=\"cbp\" type=\"password\" class=\"form-control\"\n" +
    "                   id=\"confirm_brain_passphrase\" placeholder=\"Confirm Brain Passphrase\" data-match=\"brain_passphrase\">\n" +
    "\n" +
    "            <p ng-show=\"wform.cbp.$error.match\" class=\"help-block\">Fields do not match.</p>\n" +
    "           </div>\n" +
    "          </div>\n" +
    "        </div> \n" +
    "      </div>\n" +
    "    </div>\n" +
    "    -->\n" +
    "\n" +
    "    <div class=\"form-group row\">\n" +
    "     <div class=\"col-sm-offset-2 col-sm-10\">\n" +
    "      <button type=\"submit\" class=\"btn btn-primary btn-lg\">Create Wallet</button>\n" +
    "     </div>\n" +
    "    </div>\n" +
    "   </div>\n" +
    "  </div>\n" +
    "\n" +
    "\n" +
    " </form>\n" +
    "\n" +
    "</div>\n"
  );

  $templateCache.put("footer.html",
    "<!--\n" +
    "<div class=\"pull-left\">\t\n" +
    "\t<a type=\"submit\" href='/blank.html#/createwallet' class=\"btn btn-info btn-lg\"><i class=\"fa fa-plus fa-fw\"></i> New Wallet</a>\n" +
    "</div>\n" +
    "-->\n" +
    "<div class=\"pull-left logo\">\n" +
    "\t<img src=\"/img/bts-logo-gray.png\" height=\"48\" width=\"150\"/>\n" +
    "</div>\n" +
    "<p class=\"text-muted pull-right\">\n" +
    "\t<span class=\"wallet-status\" ng-switch on=\"wallet_unlocked\">\n" +
    "\t\t<i class=\"fa fa-unlock-alt\" ng-switch-when=\"true\" tooltip=\"Wallet is unlocked\"></i>\n" +
    "\t\t<i class=\"fa fa-lock\" ng-switch-default tooltip=\"Wallet is locked\"></i>\n" +
    "\t</span>\n" +
    "\t<span class=\"blockchain-status \" ng-switch on=\"blockchain_status\">\n" +
    "\t\t<i class=\"fa fa-check\" ng-switch-when=\"synced\" tooltip=\"Up to date, processed {{blockchain_last_block_num}} blocks\"></i>\n" +
    "\t\t<i class=\"fa fa-refresh fa-spin\" ng-switch-when=\"syncing\" tooltip=\"Catching up.. processed {{blockchain_last_block_num}} out of {{blockchain_last_block_num + blockchain_blocks_behind}} blocks ({{blockchain_time_behind}} behind)\"></i>\n" +
    "\t\t<i ng-switch-default></i>\n" +
    "\t</span>\n" +
    "\t<img class=\"connections\" ng-src=\"{{connections_img}}\" alt=\"network connections\" tooltip=\"{{connections_str}}\" height=\"24\" width=\"24\"/>\n" +
    "</p>\n" +
    "\n"
  );

  $templateCache.put("home.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    "<!--<li><i class=\"fa fa-home fa-fw\"></i> Overview</li>-->\n" +
    "<!--</ol>-->\n" +
    "\n" +
    "<!--<div class=\"header\">-->\n" +
    "<!--<div class=\"col-md-12\">-->\n" +
    "<!--<h3 class=\"header-title\">Dashboard</h3>-->\n" +
    "<!--<p class=\"header-info\">Overview and latest statistics</p>-->\n" +
    "<!--</div>-->\n" +
    "<!--</div>-->\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\t<div class=\"row\">\n" +
    "\t\t<div class=\"col-sm-3\">\n" +
    "\t\t\t<div class=\"panel\">\n" +
    "\t\t\t\t<div class=\"panel-heading\">\n" +
    "\t\t\t\t\t<h3 class=\"panel-title\">AccountNameHere</h3>\n" +
    "\t\t\t\t</div>\n" +
    "\t\t\t\t<div class=\"panel-body\">\n" +
    "\t\t\t\t\t<p>{{balance_amount | currency : ''}} {{balance_asset_type}}</p>\n" +
    "\t\t\t\t</div>\n" +
    "\t\t\t</div>\n" +
    "\t\t</div>\n" +
    "\n" +
    "\t\t<div class=\"col-sm-3\">\n" +
    "\t\t\t<div class=\"panel\">\n" +
    "\t\t\t\t<div class=\"panel-heading\">\n" +
    "\t\t\t\t\t<h3 class=\"panel-title\">AnotherAccount</h3>\n" +
    "\t\t\t\t</div>\n" +
    "\t\t\t\t<div class=\"panel-body\">\n" +
    "\t\t\t\t\t<p>--another account balance --</p>\n" +
    "\t\t\t\t</div>\n" +
    "\t\t\t</div>\n" +
    "\t\t</div>\n" +
    "\t</div>\n" +
    "\n" +
    "\t<div class=\"row\">\n" +
    "\t\t<div class=\"col-sm-12\">\n" +
    "\t\t\t<h3>Latest Transactions</h3>\n" +
    "\t\t\t<table class=\"table table-striped table-hover\">\n" +
    "\t\t\t\t<thead>\n" +
    "\t\t\t\t<tr>\n" +
    "\t\t\t\t\t<th>TRX</th>\n" +
    "\t\t\t\t\t<th>CONFIRMED</th>\n" +
    "\t\t\t\t\t<th>AMOUNT</th>\n" +
    "\t\t\t\t\t<th>FROM</th>\n" +
    "\t\t\t\t\t<th>TO</th>\n" +
    "\t\t\t\t</tr>\n" +
    "\t\t\t\t</thead>\n" +
    "\t\t\t\t<tbody>\n" +
    "\t\t\t\t<tr ng-repeat=\"t in transactions\">\n" +
    "\t\t\t\t\t<td>{{ t.block_num }}/{{ t.trx_num }}</td>\n" +
    "\t\t\t\t\t<td>{{ t.time }}</td>\n" +
    "\t\t\t\t\t<td>{{ t.amount | currency : '' }}</td>\n" +
    "\t\t\t\t\t<td>{{ t.from }}</td>\n" +
    "\t\t\t\t\t<td>{{ t.to }}</td>\n" +
    "\t\t\t\t</tr>\n" +
    "\t\t\t\t</tbody>\n" +
    "\t\t\t</table>\n" +
    "\t\t</div>\n" +
    "\t</div>\n" +
    "</div>\n"
  );

  $templateCache.put("newcontact.html",
    " <div class=\"modal-header\">\n" +
    "  <h3 class=\"modal-title\">New Contact</h3>\n" +
    " </div>\n" +
    " <form role=\"form\" ng-submit=\"ok()\">\n" +
    " <div class=\"modal-body\">\n" +
    "  <div class=\"form-group\">\n" +
    "   <label for=\"contact_name\">Name</label>\n" +
    "   <input ng-model=\"$parent.name\" focus-me class=\"form-control\" id=\"contact_name\" placeholder=\"Name\" required autofocus>\n" +
    "   <br>\n" +
    "   <label for=\"contact_address\">Address</label>\n" +
    "   <input ng-model=\"$parent.address\" class=\"form-control\" id=\"contact_address\" placeholder=\"Address\">\n" +
    "  </div>\n" +
    " </div>\n" +
    " </form>\n" +
    " <div class=\"modal-footer\">\n" +
    "  <button class=\"btn btn-primary\" ng-click=\"ok()\">OK</button>\n" +
    "  <button class=\"btn btn-warning\" ng-click=\"cancel()\">Cancel</button>\n" +
    " </div>"
  );

  $templateCache.put("openwallet.html",
    " <div class=\"modal-header\">\n" +
    "  <h3 class=\"modal-title\">{{ title }}</h3>\n" +
    " </div>\n" +
    " <form role=\"form\" ng-submit=\"ok()\">\n" +
    " <div class=\"modal-body\">\n" +
    "  <div class=\"form-group\" ng-class=\"{'has-error': $parent.has_error}\">\n" +
    "   <label for=\"wallet_password\">{{ password_label }}</label>\n" +
    "   <input ng-model=\"$parent.password\" focus-me type=\"password\" class=\"form-control\" id=\"wallet_password\" placeholder=\"Password\" required autofocus>\n" +
    "   <p class=\"help-block error\" ng-show=\"$parent.has_error\">{{ wrong_password_msg }}</p>\n" +
    "  </div>\n" +
    " </div>\n" +
    " </form>\n" +
    " <div class=\"modal-footer\">\n" +
    "  <button class=\"btn btn-primary\" ng-click=\"ok()\">OK</button>\n" +
    "  <button class=\"btn btn-warning\" ng-click=\"cancel()\">Cancel</button>\n" +
    " </div>\n"
  );

  $templateCache.put("receive.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    "<!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    "<!--<li><i class=\"fa fa-sign-in fa-fw\"></i> Receive</li>-->\n" +
    "<!--</ol>-->\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    " <div class=\"row\">\n" +
    "  <div class=\"col-sm-12\">\n" +
    "\n" +
    "   <tabset>\n" +
    "\n" +
    "    <tab heading=\"Create Address\">\n" +
    "     <br/>\n" +
    "     <form class=\"form-horizontal\" role=\"form\" ng-submit=\"create_address()\">\n" +
    "      <div class=\"form-group\">\n" +
    "       <label for=\"new_address_label\" class=\"col-sm-2 control-label\">Name</label>\n" +
    "       <div class=\"col-sm-9\">\n" +
    "        <input ng-model=\"$parent.new_address_label\" type=\"text\" class=\"form-control\" id=\"new_address_label\" placeholder=\"Name\"\n" +
    "               autofocus>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "      <div class=\"form-group\">\n" +
    "       <div class=\"col-sm-offset-2 col-sm-10\">\n" +
    "        <button type=\"submit\" class=\"btn btn-primary\">Create Account</button>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "     </form>\n" +
    "\n" +
    "\n" +
    "\n" +
    "\n" +
    "    </tab>\n" +
    "\n" +
    "    <tab heading=\"Import Key\">\n" +
    "     <br/>\n" +
    "     <form class=\"form-horizontal\" role=\"form\" ng-submit=\"import_key()\">\n" +
    "      <div class=\"form-group\">\n" +
    "       <label for=\"pk_label\" class=\"col-sm-2 control-label\">Name</label>\n" +
    "       <div class=\"col-sm-9\">\n" +
    "        <input ng-model=\"$parent.pk_label\" type=\"text\" class=\"form-control\" id=\"pk_label\" placeholder=\"Name\"/>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "      <div class=\"form-group\">\n" +
    "       <label for=\"pk_value\" class=\"col-sm-2 control-label\">Private Key</label>\n" +
    "       <div class=\"col-sm-9\">\n" +
    "        <input ng-model=\"$parent.pk_value\" type=\"text\" class=\"form-control\" id=\"pk_value\" placeholder=\"Private Key\"/>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "      <div class=\"form-group\">\n" +
    "       <div class=\"col-sm-offset-2 col-sm-10\">\n" +
    "        <button type=\"submit\" class=\"btn btn-primary\">Import Key</button>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "\n" +
    "     </form>\n" +
    "    </tab>\n" +
    "\n" +
    "    <tab heading=\"Import Wallet\">\n" +
    "     <br/>\n" +
    "\n" +
    "     <form class=\"form-horizontal\" role=\"form\" ng-submit=\"import_wallet()\">\n" +
    "      <div class=\"form-group\">\n" +
    "       <label for=\"wallet_file\" class=\"col-sm-2 control-label\">Wallet Path</label>\n" +
    "       <div class=\"col-sm-9\">\n" +
    "        <input ng-model=\"$parent.wallet_file\" type=\"text\" class=\"form-control\" id=\"wallet_file\" placeholder=\"\"/>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "      <div class=\"form-group\">\n" +
    "       <label for=\"wallet_password\" class=\"col-sm-2 control-label\">Wallet Password</label>\n" +
    "       <div class=\"col-sm-9\">\n" +
    "        <input ng-model=\"$parent.wallet_password\" type=\"password\" class=\"form-control\" id=\"wallet_password\" placeholder=\"Password\"/>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "      <div class=\"form-group\">\n" +
    "       <div class=\"col-sm-offset-2 col-sm-10\">\n" +
    "        <button type=\"submit\" class=\"btn btn-primary\">Import Wallet</button>\n" +
    "       </div>\n" +
    "      </div>\n" +
    "     </form>\n" +
    "    </tab>\n" +
    "\n" +
    "   </tabset>\n" +
    "\n" +
    "  </div>\n" +
    " </div>\n" +
    "\n" +
    " <br/>\n" +
    " <div class=\"row\">\n" +
    " <div class=\"col-sm-12\">\n" +
    "  <h3>Accounts</h3>\n" +
    "  <table class=\"table table-striped table-hover\">\n" +
    "   <thead>\n" +
    "   <tr>\n" +
    "    <th>Name</th>\n" +
    "    <th>Address</th>\n" +
    "   </tr>\n" +
    "   </thead>\n" +
    "   <tbody>\n" +
    "   \n" +
    "   <tr ng-repeat=\"a in addresses\">\n" +
    "   \n" +
    "    <td><a ng-click='accountClicked(a.label, a.address)' ui-sref=\"account\"><div>{{a.label}}</div></a></td>\n" +
    "    <td>{{a.address}}</td>\n" +
    "\n" +
    "   </tr>\n" +
    "   \n" +
    "   </tbody>\n" +
    "  </table>\n" +
    " </div>\n" +
    " </div>\n" +
    "\n" +
    "</div>\n"
  );

  $templateCache.put("transactions.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    "<!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    "<!--<li><i class=\"fa fa-exchange fa-fw\"></i> Transaction History</li>-->\n" +
    "<!--</ol>-->\n" +
    "<div class=\"header\">\n" +
    "\t<div class=\"col-sm-12\">\n" +
    "\t\t<h3 class=\"header-title\">Transactions</h3>\n" +
    "\t</div>\n" +
    "</div>\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\n" +
    "\t<div id=\"transaction_history\">\n" +
    "\t\t<!--<input type=\"button\" ng-click=\"rescan()\" value=\"Rescan\" class=\"btn btn-primary pull-right\"/>-->\n" +
    "\t\t<table class=\"table table-striped table-hover\">\n" +
    "\t\t\t<thead>\n" +
    "\t\t\t<tr>\n" +
    "\t\t\t\t<th>#</th>\n" +
    "\t\t\t\t<th>BLK.TRX</th>\n" +
    "\t\t\t\t<th>TIME RECEIVED</th>\n" +
    "\t\t\t\t<th>FROM</th>\n" +
    "\t\t\t\t<th>TO</th>\n" +
    "\t\t\t\t<th>MEMO</th>\n" +
    "\t\t\t\t<th>AMOUNT</th>\n" +
    "\t\t\t\t<th>FEE</th>\n" +
    "\t\t\t\t<th>VOTE</th>\n" +
    "\t\t\t\t<th>ID</th>\n" +
    "\t\t\t</tr>\n" +
    "\t\t\t</thead>\n" +
    "\t\t\t<tbody>\n" +
    "\t\t\t<tr ng-repeat=\"t in transactions\">\n" +
    "\t\t\t\t<td>{{ t.trx_num }}</td>\n" +
    "\t\t\t\t<td>{{ t.block_num }}</td>\n" +
    "\t\t\t\t<td>{{ t.time }}</td>\n" +
    "\t\t\t\t<td>{{ t.from }}</td>\n" +
    "\t\t\t\t<td>{{ t.to }}</td>\n" +
    "\t\t\t\t<td>{{ t.memo }}</td>\n" +
    "\t\t\t\t<td>{{ t.amount | currency : '' }}</td>\n" +
    "\t\t\t\t<td>{{ t.fee }}</td>\n" +
    "\t\t\t\t<td>{{ t.vote }}</td>\n" +
    "\t\t\t\t<td>{{ t.id }}</td>\n" +
    "\t\t\t</tr>\n" +
    "\t\t\t</tbody>\n" +
    "\t\t</table>\n" +
    "\t</div>\n" +
    "\n" +
    "</div>\n" +
    "\n" +
    "</div>\n"
  );

  $templateCache.put("transfer.html",
    "<!--<ol class=\"breadcrumb\">-->\n" +
    " <!--<li><i class=\"fa fa-home fa-fw\"></i>Home</a></li>-->\n" +
    " <!--<li><i class=\"fa fa-sign-out fa-fw\"></i> Transfer</li>-->\n" +
    "<!--</ol>-->\n" +
    "\n" +
    "<div class=\"header\">\n" +
    " <div class=\"col-md-12\">\n" +
    "  <h3 class=\"header-title\">Transfer</h3>\n" +
    " </div>\n" +
    "</div>\n" +
    "\n" +
    "<div class=\"main-content\">\n" +
    "\n" +
    " <div id=\"transfer-form\">\n" +
    "  <form class=\"form-horizontal\" role=\"form\" ng-submit=\"send()\">\n" +
    "    <div class=\"form-group\">\n" +
    "      <label for=\"payfrom\" class=\"col-sm-2 control-label\">From</label>\n" +
    "      <div class=\"col-sm-10\">\n" +
    "        <input ng-model=\"payfrom\" type=\"text\" class=\"form-control\" placeholder=\"Account Name\" id=\"payfrom\"/>\n" +
    "      </div>\n" +
    "    </div>\n" +
    "\n" +
    "   <div class=\"form-group\">\n" +
    "    <label for=\"payto\" class=\"col-sm-2 control-label\">To</label>\n" +
    "\n" +
    "    <div class=\"col-sm-10\">\n" +
    "     <input ng-model=\"payto\" type=\"text\" class=\"form-control\" placeholder=\"Contact Name\" id=\"payto\"/>\n" +
    "    </div>\n" +
    "   </div>\n" +
    "   <div class=\"form-group\">\n" +
    "    <label for=\"amount\" class=\"col-sm-2 control-label\">Amount</label>\n" +
    "\n" +
    "    <div class=\"col-sm-10\">\n" +
    "     <input ng-model=\"amount\" type=\"number\" class=\"form-control\" placeholder=\"0.0\" id=\"amount\"/>\n" +
    "    </div>\n" +
    "   </div>\n" +
    "\n" +
    "    <div class=\"form-group\">\n" +
    "      <label for=\"symbol\" class=\"col-sm-2 control-label\">Symbol</label>\n" +
    "      <div class=\"col-sm-10\">\n" +
    "        <select class=\"form-control\" ng-model=\"symbol\" id='symbol'>\n" +
    "          <option>XTS</option>\n" +
    "          <option>Some other symbol</option>\n" +
    "        </select>\n" +
    "      </div>\n" +
    "    </div>\n" +
    "\n" +
    "\n" +
    "\n" +
    "   <div class=\"form-group\">\n" +
    "    <label for=\"memo\" class=\"col-sm-2 control-label\">Memo</label>\n" +
    "    <div class=\"col-sm-10\">\n" +
    "     <input ng-model=\"memo\" type=\"text\" class=\"form-control\" placeholder=\"Memo\" id=\"memo\"/>\n" +
    "    </div>\n" +
    "   </div>\n" +
    "\t\t<div class=\"form-group row\">\n" +
    "\t\t\t<div class=\"col-sm-offset-2 col-sm-10\">\n" +
    "\t\t\t\t<button type=\"submit\" class=\"btn btn-primary btn-lg\">Send</button>\n" +
    "\t\t\t</div>\n" +
    "\t\t</div>\n" +
    "  </form>\n" +
    " </div>\n" +
    "\n" +
    "</div>\n" +
    "\n" +
    "</div>\n"
  );

}]);
