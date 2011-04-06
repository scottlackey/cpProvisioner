
package Person;
    use Moose;

    has name => (
        isa => "Str",
        is  => "rw",
    );
