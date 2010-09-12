#\-E deployment

app = lambda { |env|
    case env["REQUEST_METHOD"]
    when "GET"
      case env["PATH_INFO"]
      when "/thanks"
        body = <<-EOS
<html><head><title>Thanks!</title></head><body>
<p>Thanks!</p>
<a href="/textarea">textarea test</a>
<a href="/upload">upload test</a>
</body></html>
EOS
      when "/textarea"
        body = <<-EOS
<html><head><title>upload test</title></head><body>
<form method="post" action="/textarea">
Enter something here<br />
<input type="text" name="a" /><br />
Enter some text here<br />
<textarea name="b"/></textarea><br />
<input type="submit" />
</form></body></html>
EOS
      when "/upload"
        body = <<-EOS
<html><head><title>upload test</title></head><body>
<form method="post" action="/upload" enctype="multipart/form-data">
Enter something here<br />
<input type="text" name="a" /><br />
Upload a small file here<br />
<input type="file" name="b" /><br />
<input type="submit" />
</form></body></html>
EOS
      else
        body = <<-EOS
<html><head><title>upload test</title></head><body>
<a href="/textarea">textarea test</a>
<a href="/upload">upload test</a>
</body></html>
EOS
    end
    [ 200, {}, [ body ] ]
  when "POST"
    inp = env['rack.input']
    now = Time.now.strftime("%Y%m%d-%H%M%S")
    File.open(".dst.#{env['REMOTE_ADDR']}-#{now}-#$$", "ab") do |fp|
      while buf = inp.read(16384)
        fp.write buf
      end
    end
    [ 302, { 'Location' => "http://#{env['HTTP_HOST']}/thanks" }, [] ]
  else
    [ 666, {}, [] ]
  end
}
use Rack::ContentLength
use Rack::ContentType, 'text/html'
run app
