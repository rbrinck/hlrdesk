/**
 * See http://mochajs.org/ for documentation.
 */
var chai = require('chai'),
    expect = chai.expect,
    request = require('supertest');
chai.use(require('chai-as-promised'));

describe('/', function() {
  it('should redirect if we are not signed in', function(done) {
    var server = require('../core/app');
    request(server)
      .get('/')
      .expect(302, done);
  });
});

describe('/logout', function() {
  it('should redirect to the CAS logout page', function(done) {
    var server = require('../core/app');
    request(server)
      .get('/logout')
      .expect('Location', 'https://cas.byu.edu/cas/logout')
      .expect(302, done);
  });

  it('should redirect me to my desired location after logging out', function(done) {
    var server = require('../core/app');
    var url = "http://example.com";

    request(server)
      .get('/logout?service='+url)
      .end(function() {
        request(this.res.headers.location)
          .get('')
          .expect('Location', url, done);
      });
  });
});

