function skew(vct)

    # This function forms the skew symmetric matrix for the vector argument

    [0 -vct[3] vct[2]; vct[3] 0 -vct[1]; -vct[2] vct[1] 0]

end  ## Leave