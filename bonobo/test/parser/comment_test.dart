import 'package:bonobo/ast/ast.dart';
import 'package:test/test.dart';
import 'util.dart';

void main() {
  List<Comment> parseComments(String text) => parse(text).parseComments();

  test('single line', () {
    expect(parseComments('// foo'), hasLength(1));
    expect(parseComments('// foo').first.text, 'foo');
  });

  test('two single line', () {
    expect(parseComments('// foo\n// bar'), hasLength(2));
  });

  test('multi line', () {
    var comments = parseComments('/*\n\n* foo\n\n*/');
    expect(comments, hasLength(1));
    expect(comments[0].text, 'foo');
  });

  test('unterminated multi line', () {
    var comments = parseComments('/*\n\n* foo\n\n');
    expect(comments, hasLength(1));
    expect(comments[0].text, 'foo');
  });

  test('nested multi line', () {
    var comments = parseComments('/*\n\n* foo\n\n /* bar */ baz*/');
    expect(comments, hasLength(1));
    expect(comments[0].text, 'foo\nbar\nbaz');
    expect(comments[0], const isInstanceOf<MultiLineComment>());
    var ml = comments[0] as MultiLineComment;
    expect(ml.members, hasLength(3));
    expect(ml.members[0], const isInstanceOf<MultiLineCommentText>());
    expect(ml.members[1], const isInstanceOf<NestedMultiLineComment>());
    var inner = (ml.members[1] as NestedMultiLineComment).comment;
    expect(inner.text, 'bar');
    expect(ml.members[2], const isInstanceOf<MultiLineCommentText>());
  });

  test('mixed', () {
    var comments = parseComments('/*\n\n* foo\n\n*/\n\n// bar');
    expect(comments, hasLength(2));
    expect(comments[0].text, 'foo');
    expect(comments[1].text, 'bar');
  });
}
