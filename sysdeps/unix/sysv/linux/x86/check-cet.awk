# This awk script expects to get command-line files that are each
# the output of 'readelf -n' on a single shared object.
# It exits successfully (0) if all of them contained the CET property.
# It fails (1) if any didn't contain the CET property
# It fails (2) if the input did not take the expected form.

BEGIN { result = cet = sanity = 0 }

function check_one(name) {
  if (!sanity) {
    print name ": *** input did not look like readelf -n output";
    result = 2;
  } else if (cet) {
    print name ": OK";
  } else {
    print name ": *** no CET property found";
    result = result ? result : 1;
  }

  cet = sanity = 0;
}

FILENAME != lastfile {
  if (lastfile)
    check_one(lastfile);
  lastfile = FILENAME;
}

index ($0, "Displaying notes") != 0 { sanity = 1 }
index ($0, "IBT") != 0 && index ($0, "SHSTK") != 0 { cet = 1 }

END {
  check_one(lastfile);
  exit(result);
}
