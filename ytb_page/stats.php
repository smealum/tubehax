<?php
function do_mysql_connect() {
  $conn = mysql_connect('localhost', 'smea', file_get_contents("/home/mtheall/smea_mysql_auth"));
  if($conn) {
    if(!mysql_select_db('smea_youtube_stats')) {
      mysql_close($conn);
      return 0;
    }
  }
  return $conn;
}

function insert_stat($ip, $version) {
  $conn = do_mysql_connect();
  if($conn) {
    $query = sprintf("insert into stats(ip, version, time) values('%s', '%s', NOW())",
                     mysql_real_escape_string($ip),
                     mysql_real_escape_string($version));
    if(mysql_query($query)) {
      // printf("<p>Inserted '%s' into stats</p>\n", htmlentities($ip));
    }
    mysql_close($conn);
  }
}

function read_stats() {
  $conn = do_mysql_connect();
  if($conn) {
    $query = "select * from stats";
    $result = mysql_query($query);
    while($row = mysql_fetch_assoc($result)) {
      printf("%s,%s,%s<br>\n",
             htmlentities($row['ip']),
             htmlentities($row['version']),
             htmlentities($row['time']));
    }
    mysql_close($conn);
  }
}
?>
