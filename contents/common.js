(function() {
  var q;

  if (this.qiita == null) this.qiita = {};

  q = this.qiita;

  q.logLevels = {
    DEBUG: 1,
    WARNING: 2,
    ERROR: 3,
    FATAL: 4,
    NONT: 5
  };

  q.LOG_LEVEL = q.logLevels.ERROR;

  q.DOMAIN = 'https://qiita.com';

  q.logger = {
    printLog: function(n, a, o) {
      if (o) {
        return console.log("" + n + ": " + a + " : %o", o);
      } else {
        return console.log("" + n + ": " + a);
      }
    },
    debug: function(a, o) {
      if (q.LOG_LEVEL <= q.logLevels.DEBUG) return this.printLog('DEBUG', a, o);
    },
    warn: function(a, o) {
      if (q.LOG_LEVEL <= q.logLevels.WARNING) {
        return this.printLog('WARNING', a, o);
      }
    },
    error: function(a, o) {
      if (q.LOG_LEVEL <= q.logLevels.ERROR) return this.printLog('ERROR', a, o);
    },
    fatal: function(a, o) {
      if (q.LOG_LEVEL <= q.logLevels.FATAL) return this.printLog('FATAL', a, o);
    }
  };

}).call(this);
